
let tg = window.Telegram.WebApp;
let accessToken = null;
let spinnerText = `<div class="spinner-border" role="status"><span class="visually-hidden">Loading...</span></div>`

function initPage(){
    tg.CloudStorage.getItem('userToken', function (error, userToken){
        if(error === null && userToken !== null && userToken.length > 0) location.href = '/webapps/taxi/home';
        else location.href = '/webapps/taxi/auth'
    })
}

function initAccessToken(callback=null){
    try {
        tg.CloudStorage.getItem('userToken', function (error, userToken) {
            if (error === null && userToken !== null && userToken.length > 0) {
                accessToken = userToken;
                if(callback !== null) callback()
            }
            else location.href = '/webapps/taxi/auth'
        })
    }
    catch (e){
        accessToken = null;
    }
}

function logout(){
    tg.CloudStorage.removeItem('userToken');
    location.href = '/webapps/taxi'
}


function sendRequest({url, method='get', data={}, is_json = false, success_callback = null, error_callback = null, headers = null}){
    if(accessToken !== null && headers === null){
        headers = {
            Authorization: 'Bearer ' + accessToken
        };
    }
    let params = {
        url: url,
        type: method,
        data: data,
        headers: headers,
        success: function (response){
            if(success_callback !== null) success_callback(response);
        },
        error: function (q, w, e){
            console.log(q);
            let error = q['responseJSON']['message'];
            if(error === undefined) error = q['statusText'];
            if(q['responseJSON'] !== undefined) error_callback(error);
            else error_callback(error)
        }
    }
    if(is_json){
        params['data'] = JSON.stringify(data);
        params['contentType'] = 'application/json; charset=utf-8';
        params['dataType'] = 'json';
    }
    $.ajax(params);
}


function LoadFile(handledData=null){
    try {
        let input = document.createElement('input');
        input.style.display = 'none';


        document.body.append(input);

        input.type = 'file';
        input.setAttribute('accept', 'image/*')

        input.addEventListener('change', (e) => {
            try {
                let file = e.target.files[0];
                uploadFile(file, handledData);
            }
            catch (e) {
            }
        });

        input.click();
    }
    catch (e) {
    }
}

function uploadFile(file, handledData) {
    var formData = new FormData();
    formData.append('file', file);

    $.ajax({
        type: "POST",
        url: '/kek/files/upload',
        cache: false,
        contentType: false,
        processData: false,
        data: formData,
        dataType : 'json',
        success: function(msg){
            if(msg['status'] !== 'ok'){
                showError(msg['message'])
            }
            if(handledData !== null) handledData(msg['uuid']);
        }
    });
}


function showError(text, callback=null){
    try{
        if(callback !== null)
            tg.showAlert(text, callback);
        else
            tg.showAlert(text);
    }
    catch (e){
        alert(text);
        if(callback !== null) callback()
    }
}

function initLocationManager(callback_success, callback_fail){
    tg.LocationManager.init(function (){
        if(tg.LocationManager.isLocationAvailable === false){
            return callback_fail();
        }
        if(tg.LocationManager.isAccessGranted === false){
            tg.showPopup({
                title: 'Местоположение',
                message: 'Для работы приложения необходим доступ к местоположению',
                buttons: [
                    {id: 'access', type: 'default', text: 'Открыть настройки'},
                    {id: 'close', type: 'destructive', text: 'Продолжить без местоположения'}
                ]
            }, function (field_id){
                if(field_id === 'access') return tg.LocationManager.openSettings();
                else return callback_fail()
            })
        }
        else {
            tg.LocationManager.getLocation(function (loc_data) {
                if (loc_data === null) return callback_fail();
                callback_success(loc_data['latitude'], loc_data['longitude'])
            });
        }
    });

}