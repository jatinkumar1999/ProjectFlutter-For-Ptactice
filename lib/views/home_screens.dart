import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_flutter/http_services/http_services.dart';
import 'package:project_flutter/modals/users_modal.dart';

class HomeScreens extends StatefulWidget {
  const HomeScreens({Key? key}) : super(key: key);

  @override
  State<HomeScreens> createState() => _HomeScreensState();
}

class _HomeScreensState extends State<HomeScreens>
    with SingleTickerProviderStateMixin {
  HttpServices httpServices = HttpServices();
  UserData userData = UserData();
  //?for Loading
  bool isLoading = false;
//*For Pagination
  bool scrollLoading = false;
  ScrollController? scrollController;
  TextEditingController controller = TextEditingController();
  int page = 1;
  int? totalPage;
  List<Data> data = [];
  List<Data> dumyUsersList = [];
  late Animation<double> animation;
  late AnimationController animationController;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    dumyUsersList = data;
    getData();
    animationController = AnimationController(
        vsync: this,
        duration: Duration(
          seconds: 2,
        ));

    animation =
        CurvedAnimation(parent: animationController, curve: Curves.bounceIn);
    super.initState();
  }

//?Show  Snack Bar
  createASnackBar(BuildContext context) {
    var snackBar = const SnackBar(
      content: Text(" This is a Dummy Snack Bar for Practice"),
      // animation: animation,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    // scaffoldKey.currentState?.showSnackBar(snackBar);
  }

  //!search Data via TextField
  searchViaData(String search) {
    //*Create a empty Data List
    List<Data> result = [];

    if (search.isEmpty) {
      //?Show All Users List
      result = dumyUsersList;
    } else {
      //*Filter Data
      result = data
          .where((user) =>
              user.firstName!.toLowerCase().contains(search.toLowerCase()))
          .toList();
    }
    //! Refresh UI Data
    setState(() {
      data = result;
    });
  }

//?Get Data from Api
  getData() {
    setState(() {
      isLoading = true;
    });
    httpServices.getDogsImagswithApi(pages: page).then((value) {
      userData = value as UserData;
      totalPage = userData.totalPages;
      print("totalPage==>>${totalPage}");
      data.addAll(userData.data as List<Data>);
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: controller,
          onChanged: (value) {
            print("search Value==>>$value");
            setState(() {
              searchViaData(value);
            });
          },
          decoration: const InputDecoration(hintText: "Search your Query....."),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (scrollInfo.metrics.pixels ==
                              scrollInfo.metrics.maxScrollExtent &&
                          page <= totalPage!) {
                        setState(() {
                          scrollLoading = true;
                        });
                        page++;

                        print("pages==>>${page}");
                        httpServices
                            .getDogsImagswithApi(pages: page)
                            .then((value) {
                          userData = value as UserData;
                          data.addAll(userData.data as List<Data>);
                          setState(() {
                            scrollLoading = false;
                          });
                        });
                      }
                      return true;
                    },
                    child: data.isNotEmpty
                        ? ListView.builder(
                            controller: scrollController,
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              return Container(
                                height: 100,
                                child: Card(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                        child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(
                                        "${data[index].avatar}",
                                        fit: BoxFit.fitHeight,
                                        height: 200,
                                      ),
                                    )),
                                    title: Text(
                                        "${data[index].firstName} ${data[index].lastName}"),
                                    subtitle: Text("${data[index].email}"),
                                  ),
                                ),
                              );
                            },
                          )
                        : const Center(child: Text("No User Found ")),
                  ),
                ),
                Container(
                  height: scrollLoading ? 50.0 : 0,
                  color: Colors.transparent,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                    onPressed: () => createASnackBar(context),
                    child: const Text("show snackBar"))
              ],
            ),
    );
  }
}
