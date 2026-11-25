import '/backend/schema/enums/enums.dart';

/// Единый источник: какие статусы видит каждая вкладка «Мои заказы»
/// и где заказ можно отменить. Менять только здесь — виджеты
/// (my_orders_widget, order_menu_p_o_p_u_p_widget) и тесты
/// (test/order_status_groups_test.dart) читают эти константы.

/// Водитель, вкладка «Активные»: заказ назначен ему и идёт работа.
const driverActiveStatuses = <StatusOrder>{
  StatusOrder.spec_set,
  StatusOrder.place_pickup,
  StatusOrder.at_work,
  StatusOrder.place_delivery,
};

/// Водитель, вкладка «Отклики»: открытые заказы, куда он откликнулся.
const driverBidsStatuses = <StatusOrder>{
  StatusOrder.newOrder,
};

/// Водитель, вкладка «Архив»: завершённые (completed + автоархив hidden)
/// и отменённые заказы.
const driverArchiveStatuses = <StatusOrder>{
  StatusOrder.completed,
  StatusOrder.hidden,
  StatusOrder.cancelled,
};

/// Статусы, которые водитель сознательно НЕ видит во вкладках:
/// on_confirmation показывается на странице заказа до подтверждения клиентом.
const driverTabHiddenStatuses = <StatusOrder>{
  StatusOrder.on_confirmation,
};

/// Клиент, вкладка «Активные»: всё, что ещё не в архиве.
const customerActiveStatuses = <StatusOrder>{
  StatusOrder.newOrder,
  StatusOrder.spec_set,
  StatusOrder.place_pickup,
  StatusOrder.at_work,
  StatusOrder.place_delivery,
  StatusOrder.on_confirmation,
};

/// Клиент, вкладка «Архив».
const customerArchiveStatuses = <StatusOrder>{
  StatusOrder.completed,
  StatusOrder.hidden,
  StatusOrder.cancelled,
};

/// Статусы, в которых клиенту доступна отмена заказа
/// (пункт «Отменить заказ» в меню + гард сервера cancel_order_by_customer).
const customerCancellableStatuses = <StatusOrder>{
  StatusOrder.newOrder,
  StatusOrder.spec_set,
  StatusOrder.place_pickup,
  StatusOrder.at_work,
  StatusOrder.place_delivery,
};
