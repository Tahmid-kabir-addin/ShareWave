import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/user/user_controller.dart';
import 'package:reddit/models/user_model.dart';
import 'package:reddit/theme/pallete.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/utils.dart';

// We choose stateful widget because when a user choose an image we can show the preview.
class EditUserScreen extends ConsumerStatefulWidget {
  final String uid;

  const EditUserScreen({
    super.key,
    required this.uid,
  });

  @override
  ConsumerState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends ConsumerState<EditUserScreen> {
  File? bannerFile, profileFile;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  //
  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
  }

  void save(UserModel user) {
    ref.watch(userControllerProvider.notifier).editUser(
          user: user,
          profileFile: profileFile,
          bannerFile: bannerFile,
          context: context,
          name: _nameController.text.trim(),
        );
  }

  void selectBannerImage() async {
    final res = await pickImage();

    if (res != null) {
      setState(() {
        bannerFile = File(res.files.first.path!);
      });
    }
  }

  void selectProfileImage() async {
    final res = await pickImage();

    if (res != null) {
      setState(() {
        profileFile = File(res.files.first.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(userControllerProvider);
    return ref.watch(getUserDataProvider(widget.uid)).when(
          data: (user) {
            return Scaffold(
              backgroundColor: Pallete.blackColor,
              appBar: AppBar(
                title: const Text("Edit User Profile"),
                actions: [
                  TextButton(
                    onPressed: () => save(user),
                    child: const Text("Save"),
                  ),
                ],
              ),
              body: isLoading
                  ? const Loader()
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 200,
                            child: Stack(
                              children: [
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
                                        child: bannerFile != null
                                            ? Image.file(
                                                bannerFile!,
                                                fit: BoxFit.fill,
                                              )
                                            : user.banner ==
                                                    Constants.bannerDefault
                                                ? const Icon(
                                                    Icons.camera_alt_outlined,
                                                    size: 40,
                                                  )
                                                : Image.network(
                                                    user.banner,
                                                    fit: BoxFit.fill,
                                                  ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 20,
                                  left: 20,
                                  child: GestureDetector(
                                    onTap: selectProfileImage,
                                    child: profileFile == null
                                        ? CircleAvatar(
                                            backgroundImage:
                                                NetworkImage(user.profilePic),
                                            radius: 30,
                                          )
                                        : CircleAvatar(
                                            backgroundImage:
                                                FileImage(profileFile!),
                                            radius: 30,
                                          ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              filled: true,
                              hintText: 'Name',
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(18),
                            ),
                          )
                        ],
                      ),
                    ),
            );
          },
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }
}
