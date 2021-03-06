import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'models/appstate.dart';
import 'slider_widget.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter/services.dart';


class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Client httpClient;
  Web3Client ethClient;
  int myAmount = 0;
  var myData;
  final myAddress = "0x980CBd8423BfcB7503703090e5500edA35C305b1";
  String txHash;
  bool data = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    httpClient = Client();
    ethClient = Web3Client(
        "https://kovan.infura.io/v3/949e7a9ae944419f92c8e9096f1f3454",
        httpClient);
    getBalance(myAddress);

    showOverlay2(context);
    showOverlay2(context);
    showOverlay3(context);
    showOverlay3(context);
  }

  showOverlay2(BuildContext context) async {
    OverlayState overlayState = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
            top: MediaQuery.of(context).size.height / 2.0 - 85.0,
            right: 0.0,
            child: Image.asset('assets/images/mythicStone4.png')));

    overlayState.insert(overlayEntry);
  }

  showOverlay3(BuildContext context) async {
    OverlayState overlayState = Overlay.of(context);

    OverlayEntry overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
            top: MediaQuery.of(context).size.height / 2.0 - 85.0,
            left: 0.0,
            child: Image.asset('assets/images/mythicStone4.png')));

    overlayState.insert(overlayEntry);
  }

  Future<DeployedContract> loadContract() async {
    String abi = await rootBundle.loadString("assets/abi.json");
    String contractAddress = "0xf6EEb17B0502646213032d3156ECb1c788ce12E9";

    final contract = DeployedContract(ContractAbi.fromJson(abi, "Thing"),
        EthereumAddress.fromHex(contractAddress));

    return contract;
  }

  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.call(
        contract: contract, function: ethFunction, params: args);

    return result;
  }

  Future<void> getBalance(String targetAddress) async {
    //EthereumAddress address = EthereumAddress.fromHex(targetAddress);
    List<dynamic> result = await query("getBalance", []);

    myData = result[0];
    data = true;
    setState(() {});
  }

  Future<String> sendCoin() async {
    var bigAmount = BigInt.from(myAmount);
    var response = await submit("depositBalance", [bigAmount]);

    print("Deposited");
    txHash = response;
    setState(() {});
    return response;
  }

  Future<String> withDrawCoin() async {
    var bigAmount = BigInt.from(myAmount);
    var response = await submit("withdrawBalance", [bigAmount]);

    print("Withdraw");
    txHash = response;
    setState(() {});
    return response;
  }

  Future<String> submit(String functionName, List<dynamic> args) async {
    EthPrivateKey credentials = EthPrivateKey.fromHex(
        "875adca609077681a6ec760ee789fdba7b92eeb73c6da0fa46e1806aaf717367");

    DeployedContract contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.sendTransaction(
        credentials,
        Transaction.callContract(
            contract: contract, function: ethFunction, parameters: args),
        fetchChainIdFromNetworkId: true);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Vx.red900,
      body: ZStack([
        VxBox()
            .black
            .size(context.screenWidth, context.percentHeight * 45)
            .make(),
        VStack([
          (context.percentHeight * 10).heightBox,
          Center(child: Image.asset('assets/images/Webp.net-resizeimage2.png')),
          "MYTHIC+ CHAIN"
              .text
              .fontFamily('LifeCraft')
              .xl5
              .yellow400
              .center
              .makeCentered()
              .py12(),
          Center(
              child: Image.asset(
                  'assets/images/Webp.net-resizeimage2_-_Copia-removebg-preview.png')),
          "\nWorld of Warcraft blockchain WTS\n"
              .text
              .xl2
              .gray400
              .bold
              .center
              .makeCentered()
              .py12(),
          (context.percentHeight * 1).heightBox,
          VxBox(
                  child: VStack([
            "Credits Balance"
                .text
                .gray700
                .xl2
                .semiBold
                .makeCentered(),
            10.heightBox,
            data
                ? "\$$myData".text.bold.xl6.makeCentered().shimmer()
                : CircularProgressIndicator().centered()
          ]))
              .p16
              .white
              .size(context.screenWidth, context.percentHeight * 18)
              .rounded
              .shadowXl
              .make()
              .p16(),
          30.heightBox,
          SliderWidget(
              min: 0,
              max: 100,
              finalVal: (value) {
                myAmount = (value * 100).round();
                print(myAmount);
              }).centered(),
          HStack(
            [
              FlatButton.icon(
                      onPressed: () => getBalance(myAddress),
                      color: Colors.black,
                      shape: Vx.roundedSm,
                      icon: Icon(Icons.refresh, color: Colors.white),
                      label: "Refresh".text.white.make())
                  .h(50),
              FlatButton.icon(
                      onPressed: () => sendCoin(),
                      color: Colors.lightGreen,
                      shape: Vx.roundedSm,
                      icon: Icon(Icons.call_made, color: Colors.white),
                      label: "Deposit".text.white.make())
                  .h(50),
              FlatButton.icon(
                      onPressed: () => withDrawCoin(),
                      color: Colors.red,
                      shape: Vx.roundedSm,
                      icon: Icon(Icons.call_received, color: Colors.white),
                      label: "Withdraw".text.white.make())
                  .h(50)
            ],
            alignment: MainAxisAlignment.spaceAround,
            axisSize: MainAxisSize.max,
          ).p16(),
          if (txHash != null) txHash.text.black.makeCentered().p16()
        ])
      ]),
    );
  }
}