import 'package:flutter/material.dart';
import 'package:responsi_prakmobile_mila/base_network.dart';
import 'package:responsi_prakmobile_mila/detail_matches_model.dart';
import 'package:responsi_prakmobile_mila/matches_model.dart';

class MatchDetail extends StatefulWidget {
  final MatchesModel? detail;
  const MatchDetail({Key? key, required this.detail}) : super(key: key);

  @override
  State<MatchDetail> createState() => _MatchDetailState();
}

class _MatchDetailState extends State<MatchDetail> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Match ID : ${widget.detail?.id}",
          style: const TextStyle(
              fontSize: 16
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(8),
        child: FutureBuilder(
          future: BaseNetwork.get("matches/${widget.detail?.id}"),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingSection();
            } else if (snapshot.hasError) {
              debugPrint(snapshot.toString());
              return _buildErrorSection();
            } else if (snapshot.hasData) {
              DetailMatchesModel matchModel = DetailMatchesModel.fromJson(snapshot.data);
              return _buildSuccessSection(matchModel);
            } else {
              return const ListTile(
                title: Text("Data tidak dapat ditemukan"),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildErrorSection() {
    return const Text("Error");
  }

  Widget _buildLoadingSection() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildSuccessSection(DetailMatchesModel data) {
    HomeTeamDetail? home = data.homeTeam!;
    AwayTeamDetail? away = data.awayTeam!;
    Statistics? homeStats = home.statistics!;
    Statistics? awayStats = away.statistics!;
    int passAccHome = ((homeStats.passesCompleted!.toDouble() / homeStats.passes!.toDouble()) * 100).round();
    int passAccAway = ((awayStats.passesCompleted!.toDouble() / awayStats.passes!.toDouble()) * 100).round();

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            spreadRadius: 3,
                            blurRadius:5,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      width : 150,
                      height: 120,
                      child: FittedBox(
                          fit: BoxFit.fill,
                          child: Image.network('https://countryflagsapi.com/png/${widget.detail!.homeTeam!.name!}'))),
                  Padding(padding: const EdgeInsets.all(8)),
                  Text(("${widget.detail!.homeTeam!.name!}")),
                ],

              ),
              Text(
                " ${widget.detail!.homeTeam!.goals} - ${widget.detail!.awayTeam!.goals} ",
                style: const TextStyle(
                    fontSize: 20
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            spreadRadius: 3,
                            blurRadius:5,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      width : 150,
                      height: 120,
                      child: FittedBox(
                          fit: BoxFit.fill,
                          child: Image.network('https://countryflagsapi.com/png/${widget.detail!.awayTeam!.name!}'))),
                  Padding(padding: const EdgeInsets.all(8)),
                  Text(("${widget.detail!.awayTeam!.name!}")),
                ],

              ),
            ],
          ),
          const Padding(padding: EdgeInsets.only(top: 8)),
          Text(
              "Stadium : ${data.venue}"
          ),
          const Padding(padding: EdgeInsets.only(top: 8)),
          Text(
              "Stadium : ${data.location}"
          ),
          const Padding(padding: EdgeInsets.only(top: 8)),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                border: Border.all()
            ),
            child: Column(
              children: [
                const Text("Statistics", style: TextStyle(fontSize: 24)),
                _statsBuilder("Ball Possession", homeStats.ballPossession, awayStats.ballPossession),
                _statsBuilder("Shot", homeStats.attemptsOnGoal, awayStats.attemptsOnGoal),
                _statsBuilder("Shot on Goal", homeStats.kicksOnTarget, awayStats.kicksOnTarget),
                _statsBuilder("Corners", homeStats.corners, awayStats.corners),
                _statsBuilder("Offside", homeStats.offsides, awayStats.offsides),
                _statsBuilder("Fouls Committed ", homeStats.foulsCommited, awayStats.foulsCommited),
                _statsBuilder("Pass Accuracy", "$passAccHome%", "$passAccAway%")
              ],
            ),
          ),
          const Padding(padding: EdgeInsets.only(top: 8)),
          const Text("Referees :", style: TextStyle(fontSize: 20)),
          const Padding(padding: EdgeInsets.only(top: 8)),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: data.officials!.map((ofc) {
                  return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 160,
                      width: 130,
                      decoration: BoxDecoration(
                          border: Border.all()
                      ),
                      child: Column(
                        children: [
                          Container(
                            height : 90,
                            width: 60,
                            child: const Image(
                              image: NetworkImage('https://upload.wikimedia.org/wikipedia/ar/f/f7/Fifa-logo.png'),
                            ),
                          ),
                          Text(
                            "${ofc.name}",
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "${ofc.role}",
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                  );
                }).toList(),
              )
          )
        ],
      ),
    );

  }

  Widget _statsBuilder(String title, dynamic stat1, dynamic stat2) {
    return Column(
        children: [
    const Padding(padding: EdgeInsets.only(top: 8)),
    Text(title),
    const Padding(padding: EdgeInsets.only(top: 8)),
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
    Text(
    "$stat1",
    ),
    const Text(
    "-"
    ),
    Text(
    "$stat2",
    )
    ],
    ),
    ]
    );
    }
}