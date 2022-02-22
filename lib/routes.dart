import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_renting/animations/slideLeftRoute.dart';
import 'package:flutter_renting/animations/slideRightRoute.dart';
import 'package:flutter_renting/animations/slideTopRoute.dart';
import 'package:flutter_renting/pages/auth/bindPhoneAfter3rdPartyAuth.dart';
import 'package:flutter_renting/pages/auth/bindPhoneValidateSMS.dart';
import 'package:flutter_renting/pages/auth/enterPassword.dart';
import 'package:flutter_renting/pages/auth/enterPhone.dart';
import 'package:flutter_renting/pages/auth/imageCaptcha.dart';
import 'package:flutter_renting/pages/auth/userAgreement.dart';
import 'package:flutter_renting/pages/auth/SMSValidation.dart';
import 'package:flutter_renting/pages/auth/setPassword.dart';
import 'package:flutter_renting/pages/me/agreement.dart';
import 'package:flutter_renting/pages/me/finishWorkOrder.dart';
import 'package:flutter_renting/pages/me/identification.dart';
import 'package:flutter_renting/pages/me/messageDetails.dart';
import 'package:flutter_renting/pages/me/resetPassword.dart';
import 'package:flutter_renting/pages/me/userSettings.dart';
import 'package:flutter_renting/pages/me/customerFeedback.dart';
import 'package:flutter_renting/pages/me/faq.dart';
import 'package:flutter_renting/pages/me/nickname.dart';
import 'package:flutter_renting/pages/me/addressList.dart';
import 'package:flutter_renting/pages/me/newAddress.dart';
import 'package:flutter_renting/pages/me/updateAddress.dart';
import 'package:flutter_renting/pages/me/enterOldAndNewPhone.dart';
import 'package:flutter_renting/pages/me/messages.dart';
import 'package:flutter_renting/pages/me/workOrderDetails.dart';
import 'package:flutter_renting/pages/me/workOrders.dart';
import 'package:flutter_renting/pages/myBatteries/batteryGeolocation.dart';
import 'package:flutter_renting/pages/myBatteries/batteryStatus.dart';
import 'package:flutter_renting/pages/me/clientGeolocation.dart';
import 'package:flutter_renting/pages/myBatteries/myBatteries.dart';
import 'package:flutter_renting/pages/order/continueLease.dart';
import 'package:flutter_renting/pages/order/rentOrderDetails.dart';
import 'package:flutter_renting/pages/order/serviceOrderDetails.dart';
import 'package:flutter_renting/pages/shop/confirmRentOrder.dart';
import 'package:flutter_renting/pages/shop/submitOrderSucceeded.dart';
import 'package:flutter_renting/pages/shop/rentLength.dart';
import 'package:flutter_renting/pages/shop/rentShop.dart';
import 'package:flutter_renting/pages/shop/rentedBattery.dart';
import 'package:flutter_renting/pages/shop/serviceShop.dart';
import 'package:flutter_renting/pages/shop/productDetails.dart';
import 'package:flutter_renting/pages/shop/serviceLocation.dart';

import 'animations/fadeRoute.dart';
import 'animations/slideBottomRoute.dart';

import 'package:flutter_renting/pages/order/rentOrders.dart';
import 'package:flutter_renting/pages/order/serviceOrders.dart';
import 'package:flutter_renting/pages/me/me.dart';
import 'package:flutter_renting/constants.dart';

class CustomRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteSMSValidation:
        return SlideLeftRoute(page: SMSValidation());
      case RouteFinishedUserAgreement:
        return SlideRightRoute(page: EnterPhone());
      case RouteUserAgreement:
        return SlideLeftRoute(page: UserAgreement());
      case RouteEnterPhone:
        return FadeRoute(page: EnterPhone());
      case RouteBindPhoneAfter3rdPartyAuth:
        return SlideLeftRoute(page: BindPhoneAfter3rdPartyAuth());
      case RouteBindPhoneValidateSMS:
        return SlideLeftRoute(page: BindPhoneValidateSMS());
      case RouteEnterPassword:
        return SlideLeftRoute(page: EnterPassword());
      case RouteHome:
        return FadeRoute(page: RentShop());
      case RouteRentOrders:
        return PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => RentOrders());
      case RouteRentOrderDetails:
        return SlideLeftRoute(page: RentOrderDetails());
      case RouteServiceOrders:
        return PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => ServiceOrders());
      case RouteMyBatteries:
        return FadeRoute(page: MyBatteries());
      case RouteMe:
        return FadeRoute(page: Me());
      case RouteSkipAuth:
        return SlideBottomRoute(page: RentShop());
      case RouteImageCaptcha:
        return SlideLeftRoute(page: ImageCaptcha());
      case RouteSetPassword:
        return SlideLeftRoute(page: SetPassword());
      case RouteUserSettings:
        return SlideLeftRoute(page: UserSettings());
      case RouteFeedback:
        return SlideLeftRoute(page: CustomerFeedback());
      case RouteIdentification:
        return SlideLeftRoute(page: Identification());
      case RouteFAQ:
        return SlideLeftRoute(page: FAQ());
      case RouteNickname:
        return SlideLeftRoute(page: Nickname());
      case RouteAddressList:
        return SlideLeftRoute(page: AddressList());
      case RouteNewAddress:
        return SlideLeftRoute(page: NewAddress());
      case RouteUpdateAddress:
        return SlideLeftRoute(page: UpdateAddress());
      case RouteEnterOldAndNewPhone:
        return SlideLeftRoute(page: EnterOldAndNewPhone());
      case RouteResetPassword:
        return SlideLeftRoute(page: ResetPassword());
      case RouteMessages:
        return SlideLeftRoute(page: MessagesPage());
      case RouteMessageDetails:
        return SlideLeftRoute(page: MessageDetails());
      case RouteRentShop:
        return PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => RentShop());
      case RouteServiceShop:
        return PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => ServiceShop());
      case RouteProductDetails:
        return SlideLeftRoute(page: ProductDetails());
      case RouteAgreement:
        return SlideLeftRoute(page: Agreement());
      case RouteRentLength:
        return SlideLeftRoute(page: RentLength());
      case RouteServiceLocation:
        return SlideLeftRoute(page: ServiceLocation());
      case RouteConfirmRentOrder:
        return SlideLeftRoute(page: ConfirmRentOrder());
      case RouteSubmitOrderSucceeded:
        return SlideTopRoute(page: SubmitOrderSucceeded());
      case RouteAfterSubmitOrderSucceeded:
        return SlideBottomRoute(page: RentShop());
      case RouteRentedBattery:
        return SlideLeftRoute(page: RentedBattery());
      case RouteContinueLease:
        return SlideLeftRoute(page: ContinueLease());
      case RouteServiceOrderDetails:
        return SlideLeftRoute(page: ServiceOrderDetails());
      case RouteBatteryStatus:
        return SlideLeftRoute(page: BatteryStatus());
      case RouteBatteryGeolocation:
        return SlideLeftRoute(page: BatteryGeolocation());
      case RouteClientGeolocation:
        return SlideLeftRoute(page: ClientGeolocation());
      case RouteWorkOrders:
        return SlideLeftRoute(page: WorkOrders());
      case RouteWorkOrderDetails:
        return SlideLeftRoute(page: WorkOrderDetails());
      case RouteFinishWorkOrder:
        return SlideLeftRoute(page: FinishWorkOrder());
      default:
        return MaterialPageRoute(builder: (_) => RentShop());
    }
  }
}
