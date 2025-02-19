import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:letzrentnew/Services/auth_services.dart';
import 'package:letzrentnew/Services/firebase_services.dart';
import 'package:letzrentnew/Utils/app_data.dart';
import 'package:letzrentnew/Utils/location_picker.dart';
import 'package:letzrentnew/Utils/widgets.dart';
import 'package:letzrentnew/providers/car_provider.dart';
import 'package:letzrentnew/providers/home_provider.dart';
import 'package:letzrentnew/screens/referral_screen.dart';
import 'package:letzrentnew/widgets/Cars/self_drive.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Services/car_functions.dart';
import '../Utils/functions.dart';
import '../Utils/constants.dart';
import '../screens/user_profile.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const items = [
    "assets/images/ZymoBenefits/Convenience.jpg",
    "assets/images/ZymoBenefits/CostEffective.jpg",
    "assets/images/ZymoBenefits/Flexibility.jpg",
    "assets/images/ZymoBenefits/GreatPrices.jpg",
  ];
  bool isSelfDrive = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (BuildContext context, value, Widget? child) {
        return Scaffold(
          backgroundColor: greyColor,
          body: FutureBuilder<String>(
              future: value.getLocation(),
              builder: (context, snapshot) {
                if (!snapshot.hasData &&
                    snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: spinkit);
                } else {
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    voucherFunction(value, context);
                  });
                  if (snapshot.data == null ||
                      snapshot.data!.isEmpty ||
                      snapshot.hasError) {
                    return NoLocationWidget();
                  }

                  final list = [Colors.white, Colors.white];
                  return DefaultTabController(
                    length: AppData.Categories.length,
                    child: Scaffold(
                      appBar: AppBar(
                        flexibleSpace: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: gradientColors),
                          ),
                        ),
                        actions: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () async => CommonFunctions.navigateTo(
                                  context, LocationPicker()),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: const [
                                      Text(
                                        'Location',
                                        maxLines: 1,
                                        style: TextStyle(
                                            color: whiteColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    CommonFunctions.getCityFromLocation(
                                        snapshot.data!),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: whiteColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      drawer: Drawer(child: UserProfile()),
                      body: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              height: 25,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: gradientColors),
                              ),
                            ),
                            Stack(
                              children: [
                                Container(
                                  height: MediaQuery.of(context).size.height * .5,
                                  decoration: BoxDecoration(
                                      gradient:
                                      LinearGradient(colors: gradientColors),
                                      borderRadius: const BorderRadius.vertical(
                                          bottom: Radius.circular(40))),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(8),
                                        child: bannerWidget(),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                            BorderRadius.circular(15),
                                          ),
                                          padding: const EdgeInsets.all(8),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          15),
                                                      gradient: LinearGradient(
                                                          colors: isSelfDrive
                                                              ? gradientColors
                                                              : list)),
                                                  child: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        isSelfDrive = true;
                                                      });
                                                    },
                                                    child: Padding(
                                                      padding:
                                                      const EdgeInsets.all(
                                                          18.0),
                                                      child: Text(
                                                        'For Hours Or Days',
                                                        textAlign:
                                                        TextAlign.center,
                                                        style: isSelfDrive
                                                            ? whiteTitleStyle
                                                            : titleStyle,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                        BorderRadius.circular(15),
                                                        gradient: LinearGradient(
                                                            colors: !isSelfDrive
                                                                ? gradientColors
                                                                : list)),
                                                    child: InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          isSelfDrive = false;
                                                        });
                                                      },
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(
                                                            18.0),
                                                        child: Text(
                                                          'Monthly Rental',
                                                          textAlign: TextAlign.center,
                                                          style: !isSelfDrive
                                                              ? whiteTitleStyle
                                                              : titleStyle,
                                                        ),
                                                      ),
                                                    ),
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Consumer<CarProvider>(
                                          builder: (BuildContext context, value,
                                              Widget? child) =>
                                              Column(children: [
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                                  child: Column(
                                                    children: [
                                                      Card(
                                                        shape:
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(15),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                          const EdgeInsets
                                                              .all(8.0),
                                                          child: AnimatedSwitcher(
                                                            duration: const Duration(
                                                                milliseconds:
                                                                480),
                                                            child: KeyedSubtree(
                                                              key: ValueKey<bool>(
                                                                  isSelfDrive),
                                                              child: isSelfDrive
                                                                  ? durationPicker(
                                                                  context,
                                                                  value)
                                                                  : atDurationPicker(
                                                                  context,
                                                                  value),
                                                            ),
                                                            transitionBuilder:
                                                                (child,
                                                                animation) {
                                                              return FadeTransition(
                                                                  opacity:
                                                                  animation,
                                                                  child: child);
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: .01.sh,
                                                      ),
                                                      TripDurationWidget(
                                                          duration: isSelfDrive
                                                              ? value
                                                              .getTripDuration()
                                                              : "30 Days"),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: .02.sh,
                                                ),
                                                SizedBox(
                                                    height: .06.sh,
                                                    child: value.isLoading
                                                        ? spinkit
                                                        : Padding(
                                                      padding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          horizontal:
                                                          8.0),
                                                      child: AppButton(
                                                          color: appColor,
                                                          textSize: 20,
                                                          title: 'Search'
                                                              .toUpperCase(),
                                                          screenHeight:
                                                          1.sh,
                                                          function: () => isSelfDrive
                                                              ? CarFunctions
                                                              .selfDriveNavigate(
                                                              context)
                                                              : CarFunctions()
                                                              .monthlyRentalNavigate(
                                                              context)),
                                                    )),
                                                SizedBox(
                                                  height: .01.sh,
                                                ),
                                                RecentSearches(provider: value)
                                              ])),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: .01.sh,
                            ),
                            Container(
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                  gradient:
                                  LinearGradient(colors: gradientColors)),
                              child: Column(
                                children: [
                                  Text('Why $appName?'.toUpperCase(),
                                      style: bigTitleStyle.copyWith(
                                          color: Colors.white)),
                                  SizedBox(
                                    height: .01.sh,
                                  ),
                                  CarouselSlider(
                                      items: List.generate(
                                          4,
                                              (index) => Card(
                                            shape:
                                            RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(
                                                  15),
                                            ),
                                            elevation: 5,
                                            child: ClipRRect(
                                              borderRadius:
                                              BorderRadius.circular(
                                                  15),
                                              child: Image.asset(
                                                "assets/icons/HomeIcons/${index + 1}.png",
                                              ),
                                            ),
                                          )),
                                      options: CarouselOptions(
                                        aspectRatio: 16 / 10,
                                        autoPlay: true,
                                        viewportFraction: 1,
                                        enlargeFactor: .5,
                                        enlargeCenterPage: true,
                                      )),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: .01.sh,
                            ),
                            InkWell(
                              onTap: () => CommonFunctions.navigateTo(
                                  context, ReferralScreen()),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  elevation: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CachedNetworkImage(
                                        imageUrl:
                                        "https://zymo.app/Imgs/img20.jpg"),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Container(
                              color: Colors.white,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: Text(
                                      "Zymo Benefits".toUpperCase(),
                                      style:
                                      bigTitleStyle.copyWith(color: appColor),
                                    ),
                                  ),
                                  GridView(
                                    physics: const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: .9,
                                        mainAxisSpacing: 1,
                                        crossAxisSpacing: 1),
                                    children: items.map((String imagePath) {
                                      return Builder(
                                        builder: (BuildContext context) {
                                          return Image.asset(
                                            imagePath,
                                            fit: BoxFit.contain,
                                          );
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                'Brands Available'.toUpperCase(),
                                style: bigTitleStyle.copyWith(color: appColor),
                              ),
                            ),
                            BrandImagesWidget(),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Center(
                                child: Text("CONNECT WITH US",
                                    style:
                                    TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: appColor)),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                IconButton(
                                    icon: const Icon(FontAwesomeIcons.facebook),
                                    onPressed: () {
                                      launchUrl(Uri.parse(
                                          'https://www.facebook.com/LetzRent.official/'));
                                    }),
                                IconButton(
                                    icon: const Icon(FontAwesomeIcons.instagram),
                                    onPressed: () {
                                      launchUrl(Uri.parse(
                                          'https://www.instagram.com/zymo.app'));
                                    }),
                                IconButton(
                                    icon: const Icon(FontAwesomeIcons.linkedin),
                                    onPressed: () {
                                      launchUrl(Uri.parse(
                                          'https://www.linkedin.com/company/letzrent/'));
                                    }),
                                IconButton(
                                    icon: const Icon(FontAwesomeIcons.twitter),
                                    onPressed: () {
                                      launchUrl(Uri.parse(
                                          'https://twitter.com/zymoapp'));
                                    }),
                                IconButton(
                                    icon: const Icon(FontAwesomeIcons.youtube),
                                    onPressed: () {
                                      launchUrl(Uri.parse(
                                          'https://www.youtube.com/channel/UCHUvrPwNYxw7bukWFjhNpag'));
                                    })
                              ],
                            ),
                            const SizedBox(
                              height: 12,
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }
              }),
        );
      },
    );
  }
}

  Future<void> voucherFunction(
    HomeProvider value,
    BuildContext context,
  ) async {
    await Future.delayed(twoSeconds);
    if (value.isReferral) {
      voucherPopUp(context, 'Congrats!',
          'You have won a voucher worth $rupeeSign$referralAmount!$happyEmoji$happyEmoji$happyEmoji Refer more to get more.');
      value.isReferralFunction(false);
    } else if (value.isNewUser) {
      voucherPopUp(context, 'Congrats!',
          'You have won a voucher!$happyEmoji$happyEmoji$happyEmoji Rent more to get more.');
      value.isNewUserFunction(false);
    }
  }

  Widget bannerWidget() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: SizedBox(
          height: 0.3.sh,
          width: 1.sw,
          child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: FirebaseServices().getBanner(),
              builder: (context, futureSnapshot) {
                if (!futureSnapshot.hasData) {
                  return const Center(child: spinkit);
                } else {
                  return BannerWidget(
                      images: futureSnapshot.data!.data()?['imageList']);
                }
              })),
    );
  }

  InkWell profilePictureWidget(BuildContext context, User user) {
    return InkWell(
      onTap: () =>
          //       Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => UserProfile())),
      child: CircleAvatar(
          backgroundColor: greyColor,
          child: user.photoURL != null
              ? CachedNetworkImage(
                  imageUrl: user.photoURL.toString(),
                )
              : const Icon(
                  Icons.person,
                  color: appColor,
                )),
    );
  }


class GrowTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Color color;
  const GrowTile({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.color=Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          // borderRadius: BorderRadius.circular(15),
          // gradient: LinearGradient(colors: gradientColors)
          ),
      child: Image.asset("assets/icons/HomeIcons/1.png")
    );
  }
}

class NoUserError extends StatelessWidget {
  final Function() onLogin;
  final String message;
  const NoUserError({
    super.key,
    required this.message,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: bigTitleStyle,
          ),
          SizedBox(
            height: 10,
          ),
          AppButton(
            screenWidth: .7.sw,
            screenHeight: .7.sh,
            title: 'Log in',
            function: () async {
              await CommonFunctions.navigateToSignIn(context);
              onLogin();
            }, textSize:20, color: Colors.black,
          )
        ],
      ),
    );
  }
}

class NoLocationWidget extends StatelessWidget {
  const NoLocationWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Welcome, ${Auth().getCurrentUser()?.displayName ?? ''}',
              style: bigTitleStyle),
          const SizedBox(height: 15),
          const Text(
            'Please select your location to continue.',
            style: TextStyle(fontSize: 19),
          ),
          const SizedBox(height: 50),
          PickLocationWidget(),
          SizedBox(height: .1.sh),
        ],
      ),
    );
  }
}

class CategoryWidget extends StatelessWidget {
  const CategoryWidget({
    required this.title,
    super.key,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseServices().getCategory(title),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return spinkit;
        } else {
          final Map<String, dynamic>? data = snapshot.data?.data();
          final List images = data?['images'] ?? [];
          return Row(
            children: [
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) => InkWell(
                    onTap: () => Navigator.of(context).pushNamed(title),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(),
                          // Add the borderRadius here if needed
                          // borderRadius: const BorderRadius.all(Radius.circular(20)),
                        ),
                        child: CachedNetworkImage(
                          placeholder: (context, url) => spinkit,
                          width: 0.4.sw,
                          fit: BoxFit.contain,
                          imageUrl: images[index],
                        ),
                      ),
                    ),
                  ),
                  itemCount: images.length,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                  width: 24,
                  child: FloatingActionButton(
                    onPressed: () => Navigator.of(context).pushNamed(title),
                    child: const Icon(Icons.arrow_right_alt),
                  ),
                ),
              )
            ],
          );
        }
      },
    );
  }
}
class BrandImagesWidget extends StatelessWidget {
  const BrandImagesWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: .19.sh,
      width: 1.sw,
      decoration:
          BoxDecoration(gradient: LinearGradient(colors: gradientColors)),
      child: FutureBuilder(
          future: FirebaseServices().getBrands(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return spinkit;
            } else {
              final List images = snapshot.data?['images'] ?? [];

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8),
                  child: Container(
                    width: .14.sh,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20))),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CachedNetworkImage(imageUrl: images[index]),
                    ),
                  ),
                ),
                itemCount: images.length,
              );
            }
          }),
    );
  }
}


class BannerWidget extends StatelessWidget {
  final List<Map<String, String>> images;

  const BannerWidget({Key? key, required this.images}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 5),
        autoPlayAnimationDuration: const Duration(seconds: 1),
        enlargeCenterPage: true,
        viewportFraction: 1.0, // Full width
        enableInfiniteScroll: true,
      ),
      items: images.map((e) {
        return InkWell(
          onTap: () {
            final path = e['path'] ?? '';
            if (path.isNotEmpty) {
              switch (path) {
                case '/at':
                  Navigator.pushNamed(context, '/cd', arguments: {'mode': 0});
                  break;
                case '/os':
                  Navigator.pushNamed(context, '/cd');
                  break;
                case '/wc':
                  Navigator.pushNamed(context, '/cd', arguments: {'mode': 2});
                  break;
                default:
                  Navigator.pushNamed(context, path);
                  break;
              }
            }
          },
          child: CachedNetworkImage(
            imageUrl: e['imageUrl'] ?? '',
            fit: BoxFit.cover,
            placeholder: (context, url) => Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        );
      }).toList(),
    );
  }
}

