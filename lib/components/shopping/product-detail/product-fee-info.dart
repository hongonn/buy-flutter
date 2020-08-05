import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:storeFlutter/components/app-list-tile-two-cols-icon.dart';
import 'package:storeFlutter/components/app-list-title.dart';
import 'package:storeFlutter/models/identity/location.dart';
import 'package:storeFlutter/models/shopping/easy-parcel-response.dart';
import 'package:storeFlutter/util/app-theme.dart';

abstract class ProductFeeInfo extends StatelessWidget {
  static void showProductDetailBottomSheet(BuildContext context,
      Location userAddress, List<EasyParcelResponse> shipments) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      backgroundColor: AppTheme.colorBg,
      builder: (BuildContext context) {
        return ProductFeeInfoModalBody(userAddress, shipments);
      },
    );
  }
}

class ProductFeeInfoModalBody extends StatelessWidget {
  final Location userAddress;
  final List<EasyParcelResponse> shipments;

  ProductFeeInfoModalBody(
    this.userAddress,
    this.shipments, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 500,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 50,
              decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: new BorderRadius.only(
                    topRight: const Radius.circular(10.0),
                    topLeft: const Radius.circular(10.0)),
              ),
              padding: EdgeInsets.only(
                  left: AppTheme.paddingStandard,
                  right: AppTheme.paddingStandard),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    FlutterI18n.translate(context,
                        "shopping.productDetail.deliveryFeeInformation"),
                    textAlign: TextAlign.left,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => Navigator.pop(context),
                    child: FaIcon(FontAwesomeIcons.lightTimes),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(AppTheme.paddingStandard),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    FlutterI18n.translate(
                        context, "shopping.productDetail.deliverTo"),
                    textAlign: TextAlign.left,
                    style:
                        TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        userAddress == null ||
                                userAddress.city == null ||
                                userAddress.state == null ||
                                userAddress.postcode == null
                            ? ""
                            : (userAddress.city +
                                ", " +
                                userAddress.state +
                                ", " +
                                userAddress.postcode),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: AppTheme.colorPrimary,
                            fontSize: 14),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      FaIcon(
                        FontAwesomeIcons.lightChevronRight,
                        size: 15,
                      )
                    ],
                  )
                ],
              ),
            ),
            AppListTitle(
              FlutterI18n.translate(
                  context, "shopping.productDetail.standardDelivery"),
              size: 14,
            ),
            userAddress == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                        Container(
                            color: Colors.white,
                            padding: EdgeInsets.all(AppTheme.paddingStandard),
                            child: Text(
                              FlutterI18n.translate(
                                  context, "shopping.general.noData"),
                              textAlign: TextAlign.center,
                            )),
                      ])
                : Column(children: generateDynamicList(context)),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> generateDynamicList(BuildContext context) {
    List<Widget> lists = [];
    int i = 0;
    for (var f in shipments) {
      lists.add(AppListTileTwoColsIcons(
        f.courier_name,
        "RM " + f.price.toStringAsFixed(2),
        FlutterI18n.translate(context, "shopping.productDetail.receivedBy") +
            " " +
            f.delivery_dates.from.day.toString() +
            " " +
            reformatMonth(f.delivery_dates.from.month) +
            " - " +
            f.delivery_dates.to.day.toString() +
            " " +
            reformatMonth(f.delivery_dates.to.month),
        topDivider: i == 0 ? true : false,
        imagePath: f.courier_logo,
      ));

      i++;
    }
    return lists;
  }

  String reformatMonth(int month) {
    switch (month) {
      case 1:
        return "Jan";
      case 2:
        return "Feb";
      case 3:
        return "Mar";
      case 4:
        return "Apr";
      case 5:
        return "May";
      case 6:
        return "Jun";
      case 7:
        return "Jul";
      case 8:
        return "Aug";
      case 9:
        return "Sep";
      case 10:
        return "Oct";
      case 11:
        return "Nov";
      case 12:
        return "Dec";
      default:
        return "";
    }
  }
}