import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toonflix_app/models/webtoon_detail.dart';
import 'package:toonflix_app/models/webtoon_episodes.dart';
import 'package:toonflix_app/service/api_service.dart';

import '../widgets/episode_widget.dart';

// HomeScreen 다르게 Property 사용해서 API 호출해야하므로 statful 사용
//StatefultWidget Property 접근시 widget.property 사용
class DetailScreen extends StatefulWidget {
  final String title, thumb, id;

  const DetailScreen({
    super.key,
    required this.title,
    required this.thumb,
    required this.id,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<WebToonDetail> webtoon;
  late Future<List<WebToonEpisodes>> episodes;
  late SharedPreferences prefs;
  bool isLiked = false;
  Future initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    final likedToons = prefs.getStringList("likedToons");
    if (likedToons != null) {
      if (likedToons.contains(widget.id) == true) {
        setState(() {
          isLiked = true;
        });
      }
    } else {
      prefs.setStringList("likedToons", []);
    }
  }

  @override
  void initState() {
    super.initState();
    webtoon = ApiService.getToonById(widget.id);
    episodes = ApiService.getLateEpisodesById(widget.id);
    initPrefs();
  }

  onHeartTap() async {
    final likedToons = prefs.getStringList("likedToons");
    if (likedToons != null) {
      if (isLiked) {
        likedToons.remove(widget.id);
      } else {
        likedToons.add(widget.id);
      }
    }
    await prefs.setStringList("likedToons", likedToons!);
    setState(() {
      isLiked = !isLiked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 2,
        foregroundColor: Colors.green,
        backgroundColor: Colors.white,
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 24),
        ),
        actions: [
          IconButton(
            onPressed: onHeartTap,
            icon: isLiked
                ? const Icon(Icons.favorite)
                : const Icon(Icons.favorite_outline_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: widget.id,
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(
                          blurRadius: 15,
                          offset: const Offset(10, 15),
                          color: Colors.black.withOpacity(0.5))
                    ], borderRadius: BorderRadius.circular(10)),
                    width: 250,
                    child: Image.network(
                      widget.thumb,
                      headers: const {
                        "User-Agent":
                            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36",
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            FutureBuilder(
              future: webtoon,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        snapshot.data!.about,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        "${snapshot.data!.genre}  / ${snapshot.data!.age}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  );
                }
                return const Text("...");
              },
            ),
            const SizedBox(
              height: 50,
            ),
            FutureBuilder(
              future: episodes,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: [
                      for (var episode in snapshot.data!)
                        Episode(episode: episode, webtoonId: widget.id)
                    ],
                  );
                }
                return Container();
              },
            )
          ]),
        ),
      ),
    );
  }
}
