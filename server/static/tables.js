class AdaptiveTable {
    constructor({endpoint, container, additionalParams = {}, mobileContainer = null, orderIndex = 0, tableParams = {},
                    tableDrawEvents=null}) {
        this.endpoint = endpoint;

        // Проверяем и получаем контейнер
        if (typeof container === 'string') {
            this.container = document.getElementById(container) || document.querySelector(container);
        } else {
            this.container = container;
        }

        // Проверяем, что контейнер найден
        if (!this.container) {
            throw new Error('Контейнер не найден. Убедитесь, что элемент существует в DOM.');
        }

        this.additionalParams = additionalParams;
        // this.isMobile = window.innerWidth <= 768;
        this.isMobile = false;
        this.headers = [];
        this.dataTable = null;
        this.orderIndex = orderIndex;
        this.mobileContainer = mobileContainer;
        this.tableParams = tableParams;

        // Параметры для мобильной версии
        this.currentPage = 0;
        this.pageLength = 10;
        this.searchTerm = '';
        this.sortColumn = 0;
        this.sortDirection = 'desc';
        this.filteredRecords = 0;
        this.tableDrawEvents = tableDrawEvents;

        this.init();
    }

    async init() {
        try {
            // Получаем заголовки
            await this.loadHeaders();

            // Создаем интерфейс в зависимости от устройства
            if (this.isMobile) {
                this.createMobileInterface();
            } else {
                this.createDesktopInterface();
            }
        } catch (error) {
            console.error('Ошибка инициализации таблицы:', error);
            if (this.container) {
                this.container.innerHTML = '<div class="alert alert-danger">Ошибка загрузки данных: ' + error.message + '</div>';
            }
        }
    }

    async loadHeaders() {
        const params = new URLSearchParams({
            only_headers: '1',
            is_mobile: this.isMobile,
            ...this.additionalParams
        });

        const response = await fetch(`${this.endpoint}?${params}`);
        const data = await response.json();
        this.headers = data.headers;
    }

    createDesktopInterface() {
        const tableId = 'datatable-' + Date.now();

        let tableHTML = `
                    <div class="desktop-table">
                        <table id="${tableId}" class="table table-hover">
                            <thead>
                                <tr>
                `;

        this.headers.forEach(header => {
            tableHTML += `<th>${header}</th>`;
        });

        tableHTML += `
                                </tr>
                            </thead>
                        </table>
                    </div>
                `;

        this.container.innerHTML = tableHTML;

        $(`#${tableId}`).on('preXhr.dt', function () {
            // Перед отправкой ajax-запроса
            $(`#${tableId}`).addClass('sk-loader');
        });

        $(`#${tableId}`).on('xhr.dt', function () {
            // После получения ajax-ответа
            $(`#${tableId}`).removeClass('sk-loader');
        });

        let t_params = {
            processing: true,
            serverSide: true,
            searching: true,
            search: {
                return: true  // Поиск только по Enter
            },
            ajax: {
                url: this.endpoint,
                type: 'GET',
                data: (d) => {
                    return { ...d, ...this.additionalParams };
                },
                dataSrc: 'data'
            },
            columns: this.headers.map((header, index) => ({
                data: null,
                render: function(data, type, row) {
                    return row[index] || '';
                }
            })),
            language: {
                processing: "",
                search: "",
                "searchPlaceholder": "Поиск",
                lengthMenu: "_MENU_",
                info: "Показано _START_-_END_ из _TOTAL_ записей",
                infoEmpty: "Записи не найдены",
                infoFiltered: "(отфильтровано из _MAX_ записей)",
                paginate: {
                    previous: '<span class="text-light">&laquo;</span>',
                    next: '<span class="text-light">&raquo;</span>'
                },
                emptyTable: "Нет данных для отображения"
            },
            pageLength: 25,
            responsive: true,
            ordering: true,
            order: [[this.orderIndex, 'desc']],
        };

        if(this.tableDrawEvents !== null) t_params['drawCallback'] = this.tableDrawEvents;

        // Инициализируем DataTables
        this.dataTable = $(`#${tableId}`).DataTable({...t_params, ...this.tableParams});

        // После инициализации DataTable
        const table = this.dataTable;

// Отключаем стандартные события поиска
        $(`#${tableId}_filter input`).off('keyup.DT input.DT');

// Добавляем поиск по Enter
        $(`#${tableId}_filter input`).on('keyup', function(e) {
            if (e.key === 'Enter' || e.keyCode === 13) {
                table.search(this.value).draw();
            }
        });
    }

    createMobileInterface() {
        const mobile_controls = `<div class="d-flex justify-content-between mb-2">
                                <div class="d-flex f12 align-items-center">
                                    <select class="mobile-pages" id="mobile-length">
                                        <option value="10">10</option>
                                        <option value="25">25</option>
                                        <option value="50">50</option>
                                    </select>
                                    <i class="fa-solid fa-arrow-down-wide-short ms-2" id="mobile-sort" style="font-size: 14px;"></i>
                                </div>
                                <input type="text" class="mobile-search-row" id="mobile-search" placeholder="Поиск">
                            </div>`;

        let mobileHTML = `
                    <div class="mobile-view">
                        
                        <div class="mobile-info" id="mobile-info">
                            Загрузка...
                        </div>
                        
                        <div class="mobile-controls">
                            ${mobile_controls}
                        </div>
                        
                        <div id="mobile-cards">
                            <div class="loading">
                                <i class="fas fa-spinner fa-spin"></i> Загрузка данных...
                            </div>
                        </div>
                        
                        <div class="mobile-pagination" id="mobile-pagination">
                            <!-- Пагинация будет добавлена динамически -->
                        </div>
                    </div>
                `;

        if(this.mobileContainer !== null) this.mobileContainer.innerHTML = mobileHTML;
        else this.container.innerHTML = mobileHTML;

        this.bindMobileEvents();
        this.loadMobileData();
    }

    bindMobileEvents() {
        // Поиск с задержкой
        let searchTimeout;
        document.getElementById('mobile-search').addEventListener('input', (e) => {
            clearTimeout(searchTimeout);
            searchTimeout = setTimeout(() => {
                this.searchTerm = e.target.value;
                this.currentPage = 0;
                this.loadMobileData();
            }, 500);
        });

        // Изменение количества записей на странице
        document.getElementById('mobile-length').addEventListener('change', (e) => {
            this.pageLength = parseInt(e.target.value);
            this.currentPage = 0;
            this.loadMobileData();
        });

        // Изменение сортировки
        document.getElementById('mobile-sort').addEventListener('click', (e) => {
            if(this.sortDirection === 'desc'){
                this.sortDirection = 'asc';
                $('#mobile-sort').removeClass('fa-arrow-down-wide-short').addClass('fa-arrow-down-short-wide')
            }
            else{
                this.sortDirection = 'desc';
                $('#mobile-sort').removeClass('fa-arrow-down-short-wide').addClass('fa-arrow-down-wide-short')
            }
            this.currentPage = 0;
            this.loadMobileData();
        });
    }

    async loadMobileData() {
        try {
            const params = {
                start: this.currentPage * this.pageLength,
                length: this.pageLength,
                'search[value]': this.searchTerm,
                'order[0][column]': this.sortColumn,
                'order[0][dir]': this.sortDirection,
                draw: Date.now(),
                is_mobile: this.isMobile,
                ...this.additionalParams
            };

            document.getElementById('mobile-cards').innerHTML = `<div class="loading">
                                <i class="fas fa-spinner fa-spin"></i> Загрузка данных...
                            </div>`;

            const response = await fetch(`${this.endpoint}?${new URLSearchParams(params)}`);
            const data = await response.json();

            this.totalRecords = data.recordsTotal;
            this.filteredRecords = data.recordsFiltered;

            this.renderMobileCards(data.data);
            this.renderMobilePagination();
            this.updateMobileInfo();
        } catch (error) {
            console.error('Ошибка загрузки данных:', error);
            document.getElementById('mobile-cards').innerHTML =
                '<div class="alert alert-danger">Ошибка загрузки данных</div>';
        }
    }

    renderMobileCards(data) {
        const cardsContainer = document.getElementById('mobile-cards');

        if (data.length === 0) {
            cardsContainer.innerHTML = '<div class="s-card">Записи не найдены</div>';
            return;
        }

        let cardsHTML = '';

        data.forEach((row, index) => {
            cardsHTML += '<div class="mobile-card">';

            // Заголовок карточки (первое значение как основное)
            if (row[0]) {
                cardsHTML += `<div class="mobile-card-header">${row[0]}</div>`;
            }

            // Остальные поля
            this.headers.forEach((header, headerIndex) => {
                if (headerIndex === 0 || !header.trim()) return; // Пропускаем ID и пустые заголовки

                const value = row[headerIndex] || '';
                cardsHTML += `
                            <div class="mobile-card-row">
                                <div class="mobile-card-label">${header}:</div>
                                <div class="mobile-card-value">${value}</div>
                            </div>
                        `;
            });

            // Действия (последний столбец)
            const actionsIndex = row.length - 1;
            if (row[actionsIndex] && row[actionsIndex].trim()) {
                cardsHTML += `
                            <div class="mobile-card-row">
                                <div class="mobile-card-buttons">
                                    ${row[actionsIndex]}
                                </div>
                            </div>
                        `;
            }

            cardsHTML += '</div>';
        });

        cardsContainer.innerHTML = cardsHTML;

        if(this.tableDrawEvents !== null) this.tableDrawEvents();
    }

    renderMobilePagination() {
        const totalPages = Math.ceil(this.filteredRecords / this.pageLength);
        const currentPage = this.currentPage;
        const paginationContainer = document.getElementById('mobile-pagination');

        if (totalPages <= 1) {
            paginationContainer.innerHTML = '';
            return;
        }

        // Очищаем контейнер
        paginationContainer.innerHTML = '';

        // Кнопка "Предыдущая"
        const prevBtn = document.createElement('button');
        prevBtn.className = 'btn btn-outline-primary btn-sm';
        prevBtn.innerHTML = '<i class="fas fa-chevron-left"></i>';
        prevBtn.disabled = currentPage === 0;
        if (!prevBtn.disabled) {
            prevBtn.addEventListener('click', () => this.goToPage(currentPage - 1));
        }
        paginationContainer.appendChild(prevBtn);

        // Для мобильной версии показываем максимум 3 кнопки: текущую и по одной с каждой стороны
        const startPage = Math.max(0, currentPage - 1);
        const endPage = Math.min(totalPages - 1, currentPage + 1);

        // Показываем первую страницу, если текущая не первая и не вторая
        if (currentPage > 1) {
            const firstBtn = document.createElement('button');
            firstBtn.className = 'btn btn-outline-secondary btn-sm';
            firstBtn.textContent = '1';
            firstBtn.addEventListener('click', () => this.goToPage(0));
            paginationContainer.appendChild(firstBtn);

            // Добавляем троеточие, если между первой и текущим диапазоном есть пропуск
            if (currentPage > 2) {
                const dots = document.createElement('span');
                dots.textContent = '...';
                dots.className = 'px-2';
                paginationContainer.appendChild(dots);
            }
        }

        // Отображаем страницы в диапазоне (максимум 3 кнопки)
        for (let i = startPage; i <= endPage; i++) {
            const pageBtn = document.createElement('button');
            pageBtn.className = i === currentPage ? 'btn btn-primary btn-sm' : 'btn btn-outline-secondary btn-sm';
            pageBtn.textContent = i + 1;
            if (i !== currentPage) {
                pageBtn.addEventListener('click', () => this.goToPage(i));
            }
            paginationContainer.appendChild(pageBtn);
        }

        // Показываем последнюю страницу, если текущая не последняя и не предпоследняя
        if (currentPage < totalPages - 2) {
            // Добавляем троеточие, если между текущим диапазоном и последней есть пропуск
            if (currentPage < totalPages - 3) {
                const dots = document.createElement('span');
                dots.textContent = '...';
                dots.className = 'px-2';
                paginationContainer.appendChild(dots);
            }

            const lastBtn = document.createElement('button');
            lastBtn.className = 'btn btn-outline-secondary btn-sm';
            lastBtn.textContent = totalPages;
            lastBtn.addEventListener('click', () => this.goToPage(totalPages - 1));
            paginationContainer.appendChild(lastBtn);
        }

        // Кнопка "Следующая"
        const nextBtn = document.createElement('button');
        nextBtn.className = 'btn btn-outline-primary btn-sm';
        nextBtn.innerHTML = '<i class="fas fa-chevron-right"></i>';
        nextBtn.disabled = currentPage >= totalPages - 1;
        if (!nextBtn.disabled) {
            nextBtn.addEventListener('click', () => this.goToPage(currentPage + 1));
        }
        paginationContainer.appendChild(nextBtn);
    }

    updateMobileInfo() {
        const start = this.currentPage * this.pageLength + 1;
        const end = Math.min((this.currentPage + 1) * this.pageLength, this.filteredRecords);
        const infoText = `Показано ${start}-${end} из ${this.filteredRecords} записей`;

        document.getElementById('mobile-info').textContent = infoText;
    }

    goToPage(page) {
        this.currentPage = page;
        this.loadMobileData();
    }

    // Метод для обновления параметров
    updateParams(newParams) {
        this.additionalParams = { ...this.additionalParams, ...newParams };
        this.reload();
    }

    // Метод для полной замены параметров
    setParams(newParams) {
        this.additionalParams = newParams;
        this.reload();
    }

    // Метод для получения текущих параметров
    getParams() {
        return { ...this.additionalParams };
    }

    // Метод для обновления данных извне
    reload() {
        if (this.isMobile) {
            this.currentPage = 0; // Сбрасываем на первую страницу при обновлении
            this.loadMobileData();
        } else if (this.dataTable) {
            this.dataTable.ajax.reload();
        }
    }

    // Метод для программного поиска
    search(term) {
        if (this.isMobile) {
            document.getElementById('mobile-search').value = term;
            this.searchTerm = term;
            this.currentPage = 0;
            this.loadMobileData();
        } else if (this.dataTable) {
            this.dataTable.search(term).draw();
        }
    }
}