import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:storeFlutter/blocs/navigation/bottom-navigation-bloc.dart';
import 'package:storeFlutter/blocs/shopping/sales-cart-bloc.dart';
import 'package:storeFlutter/blocs/shopping/sales-cart-content-bloc.dart';
import 'package:storeFlutter/components/account/check-session.dart';
import 'package:storeFlutter/components/app-button.dart';
import 'package:storeFlutter/components/app-confirmation-dialog.dart';
import 'package:storeFlutter/components/app-general-error-info.dart';
import 'package:storeFlutter/components/app-loading.dart';
import 'package:storeFlutter/components/app-panel.dart';
import 'package:storeFlutter/components/form/quantity-input.dart';
import 'package:storeFlutter/models/identity/company.dart';
import 'package:storeFlutter/models/shopping/quote-item.dart';
import 'package:storeFlutter/models/shopping/sales-quotation.dart';
import 'package:storeFlutter/util/app-theme.dart';
import 'package:storeFlutter/util/format-util.dart';
import 'package:storeFlutter/util/resource-util.dart';

class ShoppingCartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SalesCartContentBloc(GetIt.I<SalesCartBloc>()),
      child: BlocBuilder<SalesCartContentBloc, SalesCartContentState>(
          builder: (context, state) {
        SalesCartContentBloc contentBloc =
            BlocProvider.of<SalesCartContentBloc>(context);

        int total = contentBloc.totalCart;

        return Scaffold(
          backgroundColor: AppTheme.colorBg2,
          appBar: AppBar(
            title: Text(
              FlutterI18n.translate(context, "screen.bottomNavigation.cart") +
                  (total > 0 ? " ($total)" : ""),
              style: TextStyle(color: Colors.white),
            ),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[AppTheme.colorPrimary, AppTheme.colorSuccess],
                ),
              ),
            ),
            iconTheme: IconThemeData(color: Colors.white),
            actions: buildActions(context, contentBloc),
          ),
          body: CheckSession(
            child: ShoppingCartBody(),
          ),
        );
      }),
    );
  }

  List<Widget> buildActions(BuildContext context, SalesCartContentBloc bloc) {
    List<Widget> widgets = [];

    int total = bloc.totalCart;

    bool checkoutScreen = bloc.screenMode == ScreenMode.checkout;

    if (total > 0) {
      if (checkoutScreen) {
        widgets.add(editButton(context, bloc));
      } else {
        widgets.add(cancelButton(context, bloc));
      }
    }

    return widgets;
  }

  Widget editButton(BuildContext context, SalesCartContentBloc bloc) {
    return FlatButton(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Text(
        FlutterI18n.translate(context, "general.edit"),
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () => bloc.add(SalesCartContentScreenEdit()),
    );
  }

  Widget cancelButton(BuildContext context, SalesCartContentBloc bloc) {
    return FlatButton(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Text(
        FlutterI18n.translate(context, "general.cancel"),
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () => bloc.add(SalesCartContentScreenCheckout()),
    );
  }
}

class ShoppingCartBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SalesCartContentBloc, SalesCartContentState>(
      builder: (context, state) {
        SalesCartContentBloc bloc =
            BlocProvider.of<SalesCartContentBloc>(context);

        bool hasCartDocs = bloc.totalCart > 0;

        return Scaffold(
          bottomNavigationBar: hasCartDocs ? buildBottomAppBar(context) : null,
          body: RefreshIndicator(
            color: Colors.white,
            backgroundColor: AppTheme.colorOrange,
            onRefresh: () async {
              Completer completer = Completer();
              GetIt.I<SalesCartBloc>()
                  .add(SalesCartRefresh(completer: completer));
              return completer.future;
            },
            child: ListView(
              children: [
                ...(hasCartDocs)
                    ? [
                        SizedBox(height: 20),
                        showCartLoadingStatus(context),
                        ...bloc.cartGroups
                            .map((e) => buildCartGroup(context, e))
                            .toList()
                      ]
                    : [showCartLoadingStatus(context)]
              ],
            ),
          ),
        );
      },
    );
  }

  Widget showCartLoadingStatus(BuildContext context) {
    SalesCartBloc bloc = GetIt.I<SalesCartBloc>();

    return BlocBuilder<SalesCartBloc, SalesCartState>(
      bloc: GetIt.I<SalesCartBloc>(),
      builder: (context, state) {
        if (state is SalesCartRefreshFailed) {
          return AppGeneralErrorInfo(state.error);
        } else if (state is SalesCartRefreshInProgress &&
            state.completer == null) {
          return AppLoading();
        } else if (state is SalesCartRefreshComplete) {
          if (bloc.totalCart == 0) {
            return buildEmptyShoppingCart(context);
          }
        }
        return SizedBox.shrink();
      },
    );
  }

  Widget buildEmptyShoppingCart(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppTheme.paddingStandard),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(height: 30),
//          FlatButton(
//            child: Text("RELOAD - to be removed"),
//            onPressed: () {
//              GetIt.I<SalesCartBloc>().add(SalesCartRefresh());
//            },
//          ),
          Text(
            FlutterI18n.translate(context, "cart.shoppingCartEmpty"),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              FlutterI18n.translate(context, "cart.shoppingCartEmptyMsg"),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: AppButton(
              FlutterI18n.translate(context, "cart.goShoppingNow"),
              () => GetIt.I<BottomNavigationBloc>().add(0),
              size: AppButtonSize.small,
            ),
          )
        ],
      ),
    );
  }

  Widget buildCartGroup(BuildContext context, CartGroup cartGroup) {
    return AppPanel(
      children: <Widget>[
        buildCartHeader(context, cartGroup),
        ...buildCartItems(context, cartGroup)
      ],
    );
  }

  Widget buildCartHeader(BuildContext context, CartGroup cartGroup) {
    SalesCartContentBloc bloc = BlocProvider.of<SalesCartContentBloc>(context);

    bool checkedState = cartGroup.screenChecked;

    if (bloc.screenMode == ScreenMode.edit) {
      checkedState = cartGroup.screenEditChecked;
    }
    SalesCartContentEvent event =
        SalesCartContentCheckCompany(cartGroup.companyId, !checkedState);

    return Row(
      children: <Widget>[
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => bloc.add(event),
          child: !checkedState
              ? FaIcon(FontAwesomeIcons.lightCircle,
                  color: AppTheme.colorGray4, size: 20)
              : FaIcon(FontAwesomeIcons.solidCheckCircle,
                  color: AppTheme.colorGray7, size: 20),
        ),
        SizedBox(width: 10),
        getSellerLogo(cartGroup.company),
        Text(cartGroup.company.name, style: TextStyle(fontSize: 14)),
      ],
    );
  }

  List<Widget> buildCartItems(BuildContext context, CartGroup cartGroup) {
    List<Widget> items = [];

    cartGroup.cartDocs.map((salesQuotation) {
      salesQuotation.quoteItems.map((salesItem) {
        Widget item = buildCartItem(context, salesQuotation, salesItem);
        items.add(item);
      }).toList();
    }).toList();

    return items;
  }

  Widget getSellerLogo(Company company) {
    return Padding(
      padding: EdgeInsets.only(right: 10),
      child: SizedBox(
        height: 30,
        child: Container(
          child: Image.network(
            ResourceUtil.fullPath(company.image.imageUrl),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget buildCartItem(
      BuildContext context, SalesQuotation quotation, QuoteItem item) {
    SalesCartContentBloc bloc = BlocProvider.of<SalesCartContentBloc>(context);

    bool loading = bloc.state is SalesCartContentLoadingInProgress;
    bool editScreen = true;
    bool checkedState = item.screenChecked;

    if (bloc.screenMode == ScreenMode.edit) {
      checkedState = item.screenEditChecked;
      editScreen = false;
    }

    SalesCartContentEvent event =
        SalesCartContentCheckQuotationItem(item, !checkedState);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            bloc.add(event);
          },
          child: Row(
            children: <Widget>[
              Container(
                height: 80,
                child: Center(
                  child: !checkedState
                      ? FaIcon(FontAwesomeIcons.lightCircle,
                          color: AppTheme.colorGray4, size: 20)
                      : FaIcon(FontAwesomeIcons.solidCheckCircle,
                          color: AppTheme.colorGray7, size: 20),
                ),
              ),
              SizedBox(width: 10),
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
                child: Image.network(
                  ResourceUtil.fullPath(item.product.images[0].imageUrl),
                  fit: BoxFit.cover,
                  height: 80,
                  width: 80,
                ),
              ),
              SizedBox(width: 10),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(item.product.name),
              SizedBox(height: 10),
              ...buildVariantValue(quotation, item),
              Text(
                loading
                    ? "${item.currencyCode} -"
                    : "${item.currencyCode} ${FormatUtil.formatPrice(item.invoicePrice)}",
                style: TextStyle(
                    color: AppTheme.colorOrange, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                children: <Widget>[
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 200),
                    child: QuantityInput(
                      key: UniqueKey(),
                      quantity: item.quantity.toInt(),
                      min: item.minOrderQty,
                      max: item.maxOrderQty,
                      enabled: !loading && editScreen,
                      onChanged: (num) {
                        bloc.add(SalesCartContentChangeQuantity(item, num));
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(item.uomCode),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> buildVariantValue(SalesQuotation quotation, QuoteItem item) {
    if (item.sku != null &&
        item.sku.variantValues != null &&
        item.sku.variantValues.length > 0) {
      List<Widget> items = [];

      items.addAll(item.sku.variantValues.map((variantValue) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.colorGray2,
            borderRadius: BorderRadius.all(
              Radius.circular(5),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: Wrap(
              spacing: 5,
              runSpacing: 2,
              children: <Widget>[
                Text(
                  "${variantValue.variantType.name} : ",
                  style: TextStyle(color: AppTheme.colorGray6, fontSize: 12),
                ),
                Text(
                  "${variantValue.label}",
                  softWrap: true,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      }).toList());

      List<Widget> widgets = [];
      widgets.add(Wrap(
        spacing: 5,
        runSpacing: 5,
        children: items,
      ));

      widgets.add(SizedBox(height: 10));

      return widgets;
    } else {
      return [SizedBox.shrink()];
    }
  }

  BottomAppBar buildBottomAppBar(BuildContext context) {
    SalesCartContentBloc bloc = BlocProvider.of<SalesCartContentBloc>(context);

    return BottomAppBar(
      color: Colors.white,
      child: bloc.screenMode == ScreenMode.edit
          ? buildEditBottomContent(context)
          : buildCheckoutBottomContent(context),
    );
  }

  Widget buildCheckoutBottomContent(BuildContext context) {
    SalesCartContentBloc bloc = BlocProvider.of<SalesCartContentBloc>(context);
    bool loading = bloc.state is SalesCartContentLoadingInProgress;
    return Padding(
      padding: EdgeInsets.only(right: 20, top: 5.0, bottom: 5.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              bloc.add(SalesCartContentCheckAll(!bloc.checkAll));
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Row(
                children: <Widget>[
                  !bloc.checkAll
                      ? FaIcon(FontAwesomeIcons.lightCircle,
                          color: AppTheme.colorGray4, size: 20)
                      : FaIcon(FontAwesomeIcons.solidCheckCircle,
                          color: AppTheme.colorGray7, size: 20),
                  SizedBox(width: 10),
                  Text(
                    FlutterI18n.translate(context, "cart.all"),
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(FlutterI18n.translate(context, "cart.total")),
                  SizedBox(height: 3),
                  Text(
                    loading
                        ? "${bloc.currency} -"
                        : "${bloc.currency} ${FormatUtil.formatPrice(bloc.totalAmount)}",
                    style: TextStyle(
                        color: AppTheme.colorOrange,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(width: 10),
              AppButton(
                FlutterI18n.translate(context, "cart.checkout") +
                    ((bloc.totalItemChecked > 0 && !loading)
                        ? " (${bloc.totalItemChecked})"
                        : ""),
                () {},
                size: AppButtonSize.small,
                enabled: bloc.totalItemChecked > 0 && !loading,
                noPadding: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildEditBottomContent(BuildContext context) {
    SalesCartContentBloc bloc = BlocProvider.of<SalesCartContentBloc>(context);
    bool hasItem = bloc.totalItemEditChecked > 0;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              bloc.add(SalesCartContentCheckAll(!bloc.editCheckAll));
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Row(
                children: <Widget>[
                  !bloc.editCheckAll
                      ? FaIcon(FontAwesomeIcons.lightCircle,
                          color: AppTheme.colorGray4, size: 20)
                      : FaIcon(FontAwesomeIcons.solidCheckCircle,
                          color: AppTheme.colorGray7, size: 20),
                  SizedBox(width: 10),
                  Text(
                    FlutterI18n.translate(context, "cart.all"),
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          FlatButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Text(
              FlutterI18n.translate(context, "general.delete") +
                  (hasItem ? " (${bloc.totalItemEditChecked})" : ""),
              style: TextStyle(
                  color: hasItem ? AppTheme.colorLink : AppTheme.colorGray4),
            ),
            onPressed: hasItem
                ? () {
                    AppConfirmationDialog(context,
                        content: FlutterI18n.translate(
                            context, "cart.confirmDelete"),
                        delete: true,
                        cb: () => bloc.add(SalesCartContentDelete()));
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
