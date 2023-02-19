import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'components/pinch_zoom.dart';

class DetailImage extends StatefulWidget {
  const DetailImage({
    super.key,
    required this.files,
    required this.index,
    this.duration = const Duration(milliseconds: 400),
  });

  final List<File> files;
  final int index;
  final Duration? duration;

  @override
  State<DetailImage> createState() => _DetailImageState();
}

class _DetailImageState extends State<DetailImage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final AnimationController _animatedController;
  late TabController _tabController;
  late final PinchZoomController _controller;

  /// [AppBar]'s height
  /// this is the result of top padding + [kToolbarHeight]
  late double _appBarHeight;
  bool _visibleAppBar = true;

  @override
  void initState() {
    super.initState();
    _animatedController = AnimationController(duration: widget.duration, vsync: this);
    _tabController = TabController(
      initialIndex: widget.index,
      length: widget.files.length,
      vsync: this,
    );
    _controller = PinchZoomController(animationController: _animatedController);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _controller.reset();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appBarHeight = MediaQuery.of(context).padding.top + kToolbarHeight;
  }

  @override
  void didUpdateWidget(covariant DetailImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _animatedController.duration = widget.duration;
    _tabController = TabController(
      initialIndex: widget.index,
      length: widget.files.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animatedController.dispose();
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, kToolbarHeight),
        child: AnimatedOpacity(
          opacity: _visibleAppBar ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 100),
          child: _visibleAppBar
              ? AppBar(
                  actions: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          widget.files.removeAt(_tabController.index);
                          _tabController = TabController(
                            initialIndex: widget.index == 0 ? widget.index : widget.index - 1,
                            length: widget.files.length,
                            vsync: this,
                          );
                        });
                        if (_tabController.length == 0) {
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.delete),
                    ),
                    const SizedBox(width: 8.0)
                  ],
                )
              : SizedBox(height: _appBarHeight),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          for (final file in widget.files)
            PinchZoom(
              controller: _controller,
              child: Image.file(file),
              onTap: () {
                setState(() {
                  _visibleAppBar = !_visibleAppBar;
                });
              },
            ),
        ],
      ),
    );
  }
}
