import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/core/common/post_card.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/post/controller/post_controller.dart';
import 'package:reddit/features/post/widgets/comment_card.dart';
import 'package:reddit/models/comment_model.dart';
import 'package:reddit/models/user_model.dart';

class CommentScreen extends ConsumerStatefulWidget {
  final String postId;

  const CommentScreen({super.key, required this.postId});

  @override
  ConsumerState createState() => _CommentScreenState();
}

class _CommentScreenState extends ConsumerState<CommentScreen> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void addComment(BuildContext context, UserModel user, String postId) {
    ref.watch(postControllerProvider.notifier).addComment(
        context: context,
        user: user,
        text: _commentController.text.trim(),
        postId: postId);
    setState(() {
      _commentController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Post"),
      ),
      body: ref.watch(getPostByIdProvider(widget.postId)).when(
            data: (data) {
              return NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [];
                },
                body: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      PostCard(post: data),
                      const SizedBox(
                        height: 20,
                      ),
                      TextField(
                        onSubmitted: (val) =>
                            addComment(context, user, data.id),
                        controller: _commentController,
                        decoration: const InputDecoration(
                          filled: true,
                          hintText: "Add your thoughts here",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(18),
                        ),
                        // maxLength: 150,
                      ),
                      ref
                          .watch(allCommentsByPostIdProvider(widget.postId))
                          .when(
                              data: (data) {
                                print(data);
                                return Expanded(
                                  child: ListView.builder(
                                    itemCount: data.length,
                                    itemBuilder: (context, index) {
                                      Comment comment = data[index];
                                      return CommentCard(
                                        comment: comment,
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
            },
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}
