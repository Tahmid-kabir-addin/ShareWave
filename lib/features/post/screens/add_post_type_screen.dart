import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/features/community/controller/community_controller.dart';
import 'package:reddit/features/post/controller/post_controller.dart';
import 'package:reddit/models/community_model.dart';
import 'package:reddit/utils.dart';

class AddPostTypeScreen extends ConsumerStatefulWidget {
  final String type;

  const AddPostTypeScreen({super.key, required this.type});

  @override
  ConsumerState createState() => _AddPostTypeScreenState();
}

class _AddPostTypeScreenState extends ConsumerState<AddPostTypeScreen> {
  final _titleController = TextEditingController();
  final _linkController = TextEditingController();
  final _descriptionController = TextEditingController();
  Community? _selectedCommunity;
  List<Community> _communities = [];
  File? imageFile;

  void selectBannerImage() async {
    final res = await pickImage();

    if (res != null) {
      setState(() {
        imageFile = File(res.files.first.path!);
      });
    }
  }

  void sharePost() {
    if (widget.type == 'image' &&
        _titleController.text.isNotEmpty &&
        imageFile != null) {
      ref.watch(postControllerProvider.notifier).shareImagePost(
          title: _titleController.text.trim(),
          selectedCommunity: _selectedCommunity ?? _communities[0],
          context: context,
          imageFile: imageFile);
    } else if (widget.type == 'text' && _titleController.text.isNotEmpty) {
      ref.watch(postControllerProvider.notifier).shareTextPost(
          title: _titleController.text.trim(),
          selectedCommunity: _selectedCommunity ?? _communities[0],
          context: context,
          description: _descriptionController.text.trim());
    } else if (widget.type == 'link' &&
        _titleController.text.isNotEmpty &&
        _linkController.text.isNotEmpty) {
      ref.watch(postControllerProvider.notifier).shareLinkPost(
          title: _titleController.text.trim(),
          selectedCommunity: _selectedCommunity ?? _communities[0],
          context: context,
          link: _linkController.text.trim());
    } else {
      showSnackBar(context, "Please fill all of the fields.");
    }
  }


  @override
  void dispose() {
    super.dispose();

    _titleController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTypeImage = widget.type == 'image';
    final isTypeText = widget.type == 'text';
    final isTypeLink = widget.type == 'link';

    bool isLoading = ref.watch(postControllerProvider);

    return isLoading
        ? const Loader()
        : Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text("Post ${widget.type}"),
              actions: [
                TextButton(
                  onPressed: () => sharePost(),
                  child: const Text("Share"),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      filled: true,
                      hintText: "Add Title Here",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(18),
                    ),
                    maxLength: 150,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  if (isTypeImage)
                    GestureDetector(
                      onTap: () => selectBannerImage(),
                      child: DottedBorder(
                        borderType: BorderType.RRect,
                        dashPattern: const [10, 4],
                        strokeCap: StrokeCap.round,
                        radius: const Radius.circular(10),
                        color: Colors.white,
                        child: Container(
                          // width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: imageFile != null
                                ? Image.file(
                                    imageFile!,
                                    fit: BoxFit.fill,
                                  )
                                : const Icon(
                                    Icons.camera_alt_outlined,
                                    size: 40,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  if (isTypeText)
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        filled: true,
                        hintText: "Add Description Here",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(18),
                      ),
                      maxLines: 5,
                    ),
                  if (isTypeLink)
                    TextField(
                      controller: _linkController,
                      decoration: const InputDecoration(
                        filled: true,
                        hintText: "Add Link Here",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(18),
                      ),
                      maxLength: 100,
                    ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text("Select Community"),
                  ref.watch(userCommunitiesProvider).when(
                      data: (data) {
                        if (data.isEmpty) return const SizedBox();
                        _communities = data;
                        return Align(
                          alignment: Alignment.center,
                          child: DropdownButton(
                            value: _selectedCommunity ?? data[0],
                            items: data
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e.name),
                                    ))
                                .toList(),
                            onChanged: (e) {
                              setState(
                                () {
                                  _selectedCommunity = e;
                                },
                              );
                            },
                          ),
                        );
                      },
                      error: (error, stackTrace) =>
                          ErrorText(error: error.toString()),
                      loading: () => const Loader()),
                ],
              ),
            ),
          );
  }
}
