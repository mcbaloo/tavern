import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:provider/provider.dart';
import 'package:pub_client/pub_client.dart' hide Tab;
import 'package:tavern/screens/bloc.dart';
import 'package:tavern/src/pub_colors.dart';
import 'package:tavern/widgets/html_view.dart';
import 'package:tavern/widgets/score_tab.dart';
import 'package:url_launcher/url_launcher.dart';

class PackageDetailsPage extends StatefulWidget {
  static const routeName = '/packageDetailsPage';
  final PackageDetailsState packageDetailsState;

  const PackageDetailsPage({Key key, @required this.packageDetailsState})
      : super(key: key);

  @override
  _PackageDetailsPageState createState() => _PackageDetailsPageState();
}

class _PackageDetailsPageState extends State<PackageDetailsPage>
    with SingleTickerProviderStateMixin {
  List<Tab> _tabs;
  TabController _tabController;
  ScrollController _scrollViewController;
  Color scoreColor;

  @override
  void initState() {
    _tabController = TabController(length: 7, vsync: this);
    _scrollViewController = ScrollController();
    BackButtonInterceptor.add(interceptBackButton);

    super.initState();
  }

  @override
  void dispose() {
    _scrollViewController.dispose();
    _tabController.dispose();
    BackButtonInterceptor.remove(interceptBackButton);

    super.dispose();
  }

  bool interceptBackButton(stopDefaultButtonEvent) {
    Navigator.pop(context);
    //Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    return true;
  }

  FullPackage get _package => widget.packageDetailsState.package;

  PackageDetailsState get packageDetailsState => widget.packageDetailsState;

  @override
  Widget build(BuildContext context) {
    if (packageDetailsState is InitialPackageDetailsState) {
      return Material(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    _getScoreColor(context);
    _tabs = [
      Tab(
        child: Text(
          'Readme',
          style: TextStyle(
            color: DynamicTheme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
          ),
        ),
      ),
      Tab(
        child: Text(
          'Changelog',
          style: TextStyle(
            color: DynamicTheme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
          ),
        ),
      ),
      Tab(
        child: Text(
          'Example',
          style: TextStyle(
            color: DynamicTheme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
          ),
        ),
      ),
      Tab(
        child: Text(
          'Installing',
          style: TextStyle(
            color: DynamicTheme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
          ),
        ),
      ),
      Tab(
        child: Text(
          'Versions',
          style: TextStyle(
            color: DynamicTheme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
          ),
        ),
      ),
      Tab(
        child: CircleAvatar(
          backgroundColor: scoreColor,
          child: Text(
            widget.packageDetailsState.package.score.toString(),
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
      Tab(
        child: Text(
          'About',
          style: TextStyle(
            color: DynamicTheme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
          ),
        ),
      ),
    ];
    return Scaffold(
        body: NestedScrollView(
      controller: _scrollViewController,
      headerSliverBuilder: (context, innerBoxScrolled) {
        return <Widget>[
          SliverAppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).canvasColor,
            elevation: 0,
            pinned: true,
            floating: true,
            title: Text(
              '${_package.name} '
              '${_package.latestVersion.major}'
              '.${_package.latestVersion.minor}'
              '.${_package.latestVersion.patch}',
              style: TextStyle(
                color: DynamicTheme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
              ),
            ),
            bottom: TabBar(
              tabs: _tabs,
              controller: _tabController,
              isScrollable: true,
            ),
            actions: <Widget>[
              IconButton(
                icon: Text(
                  'API',
                  style: TextStyle(
                    color:
                        DynamicTheme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white,
                  ),
                ),
                onPressed: () => launch(_package.apiReferenceUrl),
              ),
              if (_package.repositoryUrl != null)
                IconButton(
                  icon: Icon(
                    Icons.code,
                    color:
                        DynamicTheme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white,
                  ),
                  onPressed: () => launch(_package.repositoryUrl),
                )
              else
                Container(),
              if (_package.issuesUrl != null)
                IconButton(
                  icon: Icon(
                    Icons.bug_report,
                    color:
                        DynamicTheme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white,
                  ),
                  onPressed: () => launch(_package.issuesUrl),
                )
              else
                Container(),
              IconButton(
                icon: Icon(
                  Icons.favorite_border,
                  color: DynamicTheme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                ),
                onPressed:
                    () {}, //TODO handle favoriting and unfavoriting packages
              ),
            ],
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          ReadmeTab(
            package: _package,
          ),
          ChangelogTab(
            package: _package,
          ),
          if (_package.tabs[2].content.isEmpty)
            Center(
              child: Text('No Example'),
            )
          else
            ExampleTab(
              package: _package,
            ),
          InstallingTab(
            package: _package,
          ),
          VersionsTab(
            package: _package,
          ),
          ScoreTab(
            package: _package,
          ),
          AboutTab(
            package: _package,
          ),
        ],
      ),
    ));
  }

  void _getScoreColor(BuildContext context) {
    int score = _package.score;
    if (score <= 50 || score == null) {
      scoreColor = Provider.of<PubColors>(context).badPackageScore;
    } else if (score >= 51 && score <= 69) {
      scoreColor = Provider.of<PubColors>(context).goodPackageScore;
    } else {
      scoreColor = Provider.of<PubColors>(context).greatPackageScore;
    }
  }
}

class PackageDetailsArguments {
  final String packageName;
  final String packageScore;

  PackageDetailsArguments(this.packageName, this.packageScore);
}

class VersionsTab extends StatelessWidget {
  final FullPackage package;

  const VersionsTab({Key key, this.package}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: package.versions.length,
      itemBuilder: (context, index) {
        //TODO: Build a table with Version, Uploaded Date, Documentation URL, and Archive columns
        return ListTile(
          title: Text('${package.versions[index].semanticVersion.major}'
              '.${package.versions[index].semanticVersion.minor}'
              '.${package.versions[index].semanticVersion.patch}'),
        );
      },
    );
  }
}

class InstallingTab extends StatelessWidget {
  final FullPackage package;

  const InstallingTab({Key key, this.package}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: HtmlView(
            html: package.tabs[3].content,
          ),
        ),
      ],
    );
  }
}

class ExampleTab extends StatelessWidget {
  final FullPackage package;

  const ExampleTab({Key key, this.package}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: HtmlView(
            html: package.tabs[2].content,
          ),
        ),
      ],
    );
  }
}

class ChangelogTab extends StatelessWidget {
  final FullPackage package;

  const ChangelogTab({Key key, this.package}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: HtmlView(
            html: package.tabs[1].content,
          ),
        ),
      ],
    );
  }
}

class ReadmeTab extends StatelessWidget {
  final FullPackage package;

  const ReadmeTab({Key key, this.package}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: HtmlView(
            html: package.tabs[0].content,
          ),
        ),
      ],
    );
  }
}

class AboutTab extends StatelessWidget {
  final FullPackage package;

  const AboutTab({Key key, this.package}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
          child: Text(package.description),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16, right: 16, left: 16),
          child: Row(
            children: <Widget>[
              Text('Author: ${package.author}'),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
          child: Row(
            children: <Widget>[
              Text('Uploaders:'),
            ],
          ),
        ),
        for (String uploader in package.uploaders)
          Padding(
            padding: EdgeInsets.only(left: 8, right: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(uploader),
                FlatButton.icon(
                  icon: Icon(Icons.mail_outline),
                  label: Text('Email'),
                  onPressed: () => launch('mailto:$uploader'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class ErrorReport extends StatelessWidget {
  final AsyncSnapshot snapshot;

  const ErrorReport({Key key, this.snapshot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            snapshot.error.toString(),
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
              'This error was unexpected. Please file an issue on our GitHub repository so we can fix it.'),
        ),
        RaisedButton.icon(
          icon: Icon(GroovinMaterialIcons.github_circle),
          label: Text('File Issue'),
          onPressed: () {
            //TODO: launch new issue page for our repo, pass in error if possible
          },
        ),
      ],
    );
  }
}