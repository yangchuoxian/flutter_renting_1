import 'package:flutter/cupertino.dart';

// ================================ routes
const RouteSMSValidation = '/smsValidation';
const RouteUserAgreement = '/userAgreement';
const RouteEnterPhone = '/enterPhone';
const RouteBindPhoneAfter3rdPartyAuth = '/bindPhone'; // 第一次第三方登录（微信登录/支付宝登录）成功后的绑定手机号的界面
const RouteBindPhoneValidateSMS = '/bindPhoneValidateSMS'; // 第一次第三方登录成功后绑定手机号过程中验证短信码的界面
const RouteEnterPassword = '/enterPassword';
const RouteHome = '/home';
const RouteOrders = '/orders';
const RouteMyBatteries = '/my_batteries';
const RouteMe = '/me';
const RouteSkipAuth = '/skipAuth';
const RouteFinishedUserAgreement = '/finishedUserAgreement';
const RouteImageCaptcha = '/imageCaptcha';
const RouteSetPassword = '/setPassword';
const RouteUserSettings = '/userSettings';
const RouteFeedback = '/feedback';
const RouteIdentification = '/identification';
const RouteFAQ = '/faq';
const RouteNickname = '/nickname';
const RouteAddressList = '/my_addresses';
const RouteNewAddress = '/new_address';
const RouteUpdateAddress = '/update_address';
const RouteEnterOldAndNewPhone = '/enter_old_and_new_phone';
const RouteResetPassword = '/reset_password';
const RouteMessages = '/messages';
const RouteMessageDetails = '/message_details';
const RouteRentShop = '/rent_shop'; // 首页的租赁tab
const RouteServiceShop = '/service_shop'; // 首页的服务tab
const RouteProductDetails = '/product_details'; // 商品详情页
const RouteAgreement = '/agreement'; // 登录后的用户协议、服务政策或租赁协议
const RouteRentLength = '/rent_length'; // 租赁过程中选择租赁时长的界面
const RouteServiceLocation = '/service_location'; // 上门服务地点
const RouteConfirmRentOrder = '/confirm_rent_order'; // 确认订单
const RouteSubmitOrderSucceeded = '/submit_order_succeeded'; // 提交订单并且付款成功
const RouteAfterSubmitOrderSucceeded =
    '/after_submit_order_succeeded'; // 显示付款成功后2秒钟，app会自动跳回到商店首页
const RouteRentedBattery = '/rented_battery'; // 已租的电池，生成服务订单时选择哪个电池需要服务
const RouteRentOrders = '/rent_orders'; // 租赁订单列表
const RouteServiceOrders = '/service_orders'; // 服务订单列表
const RouteRentOrderDetails = '/rent_order_details'; // 租赁订单详情
const RouteServiceOrderDetails = '/service_order_details'; // 服务订单详情
const RouteContinueLease = '/continue_lease'; // 续租
const RouteBatteryStatus = '/battery_status'; // 电池状态
const RouteBatteryGeolocation = '/battery_geolocation'; // 电池地理位置
const RouteClientGeolocation = '/client_geolocation'; // 工单客户的地址位置
const RouteWorkOrders = '/work_orders'; // 服务人员的工单列表
const RouteWorkOrderDetails = '/work_order_details'; // 某个工单详情
const RouteFinishWorkOrder = '/finish_work_order'; // 服务人员完成工单
// end of routes =========================

// ================================ colors
const colorPrimary = Color(0xFF0167E3);
const colorDisabled = Color(0xFF666666);
const colorBodyText = Color(0xFF666666);
const colorDarkGrey = Color(0xFFC4C4C4);
const colorGeneralBackground = Color(0xFFF2F2F2);
const colorFailure = Color(0xA3EB5757);
const colorSuccess = Color(0xA36FCF97);
// end of colors =========================

// ================================ backend APIs
// const baseURL = 'http://192.168.1.15:6868';
const baseURL = 'https://bms.piizu.com';
const apiImageCaptcha = '/image_captcha';
const apiGetAgreementURL = '/agreement';
const apiValidateImageCaptcha = '/validate_image_captcha';
const apiSMSCode = '/sms_code';
const apiValidateSMSCodeForLoginOrRegistration =
    '/validate_sms_code_for_login_or_registration';
const apiSetPassword = '/set_password';
const apiLoginWithPassword = '/login_with_password';
const apiCheckLoginStatus = '/check_login_status';
const apiUploadAvatar = '/upload_avatar';
const apiSubmitFeedback = '/submit_feedback';
const apiSubmitIdentification = '/submit_identification';
const apiListFAQs = '/list_faqs';
const apiUpdateNickname = '/update_nickname';
const apiGetUserAddresses = '/get_user_addresses';
const apiCreateNewAddress = '/create_new_address';
const apiUpdateAddress = '/update_address';
const apiValidateOldPhoneToSetNewPhone = '/validate_old_phone_to_set_new_phone';
const apiValidateSMSCodeForSetNewPhone = '/validate_sms_code_for_set_new_phone';
const apiValidateSMSCodeForResetPassword =
    '/validate_sms_code_for_reset_password';
const apiResetPassword = '/reset_password';
const apiCountUnreadMessages = '/count_unread_messages';
const apiGetMessages = '/paginated_messages';
const apiMarkAsReadOrUnread = '/mark_as_read_or_unread';
const apiListCategories = '/list_main_categories';
const apiListProductsInCategory = '/list_products_in_category';
const apiCreateOrderAndPay = '/create_rent_order_and_pay';
const apiGetOrders = '/get_orders_with_type';
const apiCreateServiceOrder = '/create_service_order';
const apiCancelOrUncancelLease = '/cancel_or_uncancel_lease';
const apiContinueLease = '/continue_lease';
const apiCancelServiceOrder = '/cancel_service_order';
const apiGetBatteryStatus = '/get_battery_status';
const apiGetBatteryLocation = '/get_battery_location';
const apiGetAssignedOrdersForServicePersonnel =
    '/get_assigned_orders_for_service_personnel';
const apiGetAddressForWorkOrder = '/get_address_for_work_order';
const apiAlipayAuthStr = '/alipay_auth_str';
const apiAlipayUserInfo = '/alipay_user_info';
const apiWXUserInfo = '/wx_user_info';
const apiSendSMSToBindPhone = '/send_sms_to_bind_phone';
const apiValidateSMSToBindPhone = '/validate_sms_to_bind_phone';
const apiFinishWorkOrder = '/finish_work_order';
const apiRegisterJPushRegistrationID = '/register_jpush_registration_id';
const apiReportBug = '/report_bug';
// end of backend APIs =========================

// ================================ paddings
const padding8 = 8.0;
const padding16 = 16.0;
const padding24 = 24.0;
const padding32 = 32.0;
const padding48 = 48.0;
const padding64 = 64.0;
// end of paddings =========================

// ================================ sizes
const tableEntryHeight = 44.0;
const smallAvatar = 32.0;
const largeAvatar = 56.0;
const defaultListTileHeight = 56.0;
const maxUploadImageSize = 168.0;
const sidebarWidth = 100.0;
const bodyTextSize = 14.0;
const subtitleTextSize = 16.0;
const titleTextSize = 18.0;
const double splashImageWidth = 280;
const double splashImageHeight = 364;
const double captchaHeight = 100.0;
const double circularBorderRadius = 96.0;
const double illustrationSize = 124;
const double blockSize = 136;
// end of sizes =========================

// ================================ backend related data types
const smsTypeResetPassword = "resetPassword";
const smsTypeRegistrationOrLogin = "registrationOrLogin";
const smsTypeSetNewPhone = "setNewPhone";
// end of backend related data types =========================

const int splashScreenDelay = 2;
const int defaultTimeDelay = 2;

// 协议类型
const articleTypeUserAgreement = 0;
const articleTypeRentAgreement = 1;
const articleTypeServiceAgreement = 2;

// 订单类型
const orderTypeRentProductYearly = 0; // 以年为单位租赁的订单
const orderTypeRentProductMonthly = 1; // 以月为单位租赁订单
const orderTypeBuyProduct = 2; // 购买商品的订单
const orderTypeRoadRescue = 3; // 道路救援的服务订单
const orderTypeFixBattery = 4; // 电池故障报修的服务订单
const orderTypeBatteryMissing = 5; // 电池丢失报丢的服务订单

// 订单状态
const orderStatusOngoing = 0;
// OrderStatusPaid 表示订单的如下两种情况
// 1. 用户已经完成支付，但是还没有拿到租赁的商品，
// 2. 或者用户已经在手机app上报修/报警/报道路救援，但是服务人员还没有上门服务,
const orderStatusPaid = 1;
// OrderStatusCancelingLease 正在退租中的订单，也就是用户提交了退租申请，但是客服人员还没有上门回收电池
const orderStatusCancelingLease = 2;
// OrderStatusFinished 已完成的订单，租赁单和服务单都可以有这个状态
const orderStatusFinished = 3;
// OrderStatusCanceled 已取消的订单，只有等待客服人员上门的服务单可以被取消
const orderStatusCanceled = 4;
// OrderStatusWaitingForRefund 等待退款中， 退租订单在服务人员将电池退回到仓库后，需由后台管理人员审批后确定退押金
const orderStatusWaitingForRefund = 5;

// 支付方式
const paymentAlipay = 0;
const paymentWechatPay = 1;

enum CustomTab {
  Home,
  Orders,
  MyBatteries,
  Me,
}
enum MessageType {
  System,
  Promotion,
  Knowledge,
}
enum ImageType {
  asset, // 本地asset文件夹中的图片
  network, // 网络图片
}
enum UserRole {
  superAdmin,
  editor,
  districtRepresentative,
  agency,
  customer,
  servicePersonnel,
}
enum Gender {
  male,
  female,
}
// ================================ pick image type
enum ImagePickerType {
  fromGallery,
  byCamera,
}
// end of pick image type =========================

enum SMSProcessType {
  loginOrRegistration,
  setNewPhone,
  resetPassword,
}

enum MessageStatus {
  read,
  unread,
}

// serviceLocation 页面在多处都会用到，具体有如下几个地方
enum ServiceLocationPlaces {
  rentingBattery, // 租电池
  creatingServiceOrder, // 创建服务单
  cancelingLease, // 退租
}

const alipayAuth = 1;
const wechatAuth = 2;

// ycx!!!!!! TODO: 需要填写真实有效的电话
const customerPhoneNumber = "40000000000";
const wxAppID = 'wx50adf1f78335aca6';
const baiduIOSAPIKey = 'Sm8IkKN1UnsCfPmxM5fTpaRGhG9ldIwA';
const jpushAppKey = '79b6174ee5ba98ea273c9d2a';
const iosUniversalLink = 'https://bms.piizu.com/ulink/';
