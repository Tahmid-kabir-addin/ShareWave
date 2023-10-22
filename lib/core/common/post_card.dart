import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/Theme/pallete.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/community/controller/community_controller.dart';
import 'package:reddit/features/post/controller/post_controller.dart';
import 'package:reddit/models/post_model.dart';
import 'package:routemaster/routemaster.dart';

class PostCard extends ConsumerWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTypeImage = post.type == 'image';
    final isTypeText = post.type == 'text';
    final isTypeLink = post.type == 'link';
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;

    void deletePost(Post post) {
      ref
          .watch(postControllerProvider.notifier)
          .deletePost(user, post, context);
    }

    void updateVote(String uid, Post post, String voteType) {
      ref
          .watch(postControllerProvider.notifier)
          .updateVote(post, context, voteType, uid);
    }

    void navigateToUser(BuildContext context) {
      Routemaster.of(context).push('user/${post.uid}');
    }

    void navigateToCommunity(BuildContext context) {
      Routemaster.of(context).push('r/${post.communityName}');
    }

    void navigateToCommentScreen(BuildContext context, String postId) {
      // print('ok');
      Routemaster.of(context).push('post/$postId/comments');
    }

    void awardPost(WidgetRef ref, String award) {
      ref
          .watch(postControllerProvider.notifier)
          .awardPost(user, award, context, post);
    }

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Pallete.darkModeAppTheme.drawerTheme.backgroundColor,
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 16)
                          .copyWith(right: 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => navigateToCommunity(context),
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        post.communityProfilePic,
                                      ),
                                      radius: 16,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "r/${post.communityName}",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => navigateToUser(context),
                                          child: Text(
                                            "u/${post.userName}",
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (post.uid == user.uid)
                                IconButton(
                                  onPressed: () => deletePost(post),
                                  icon: Icon(
                                    Icons.delete,
                                    color: Pallete.redColor,
                                  ),
                                ),
                            ],
                          ),
                          if (post.awards.isNotEmpty) ...[
                            const SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                              height: 25,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: post.awards.length,
                                itemBuilder: (context, index) {
                                  final award = post.awards[index];
                                  // print(award);
                                  return Image.asset(
                                    Constants.awards[award]!,
                                    height: 23,
                                  );
                                },
                              ),
                            ),
                          ],
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              post.title,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isTypeImage)
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.35,
                              width: double.infinity,
                              child: Image.network(
                                post.image!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          if (isTypeLink)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: SizedBox(
                                height: 120,
                                width: double.infinity,
                                child: AnyLinkPreview(
                                  link: post.link!,
                                  displayDirection:
                                      UIDirection.uiDirectionHorizontal,
                                ),
                              ),
                            ),
                          if (isTypeText)
                            Container(
                              alignment: Alignment.bottomLeft,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                ),
                                child: Text(
                                  post.description!,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: isGuest? () {}: () =>
                                  updateVote(user.uid, post, 'upVote'),
                              icon: Icon(
                                Constants.up,
                                size: 30,
                                color: post.upVotes.contains(user.uid)
                                    ? Pallete.redColor
                                    : null,
                              ),
                            ),
                            Text(
                              '${post.upVotes.length - post.downVotes.length == 0 ? "Vote" : post.upVotes.length - post.downVotes.length}',
                              style: const TextStyle(
                                fontSize: 17,
                              ),
                            ),
                            IconButton(
                              onPressed: isGuest? () {}: () =>
                                  updateVote(user.uid, post, 'downVote'),
                              icon: Icon(
                                Constants.down,
                                size: 30,
                                color: post.downVotes.contains(user.uid)
                                    ? Pallete.blueColor
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () =>
                              navigateToCommentScreen(context, post.id),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.comment,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                '${post.commentCount == 0 ? "Comment" : post.commentCount}',
                                style: const TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ref
                            .watch(
                                getCommunityByNameProvider(post.communityName))
                            .when(
                              data: (data) {
                                if (data.mods.contains(user.uid)) {
                                  return IconButton(
                                      onPressed: () {},
                                      icon: const Icon(
                                          Icons.admin_panel_settings));
                                }
                                return const SizedBox();
                              },
                              error: (error, stackTrace) =>
                                  ErrorText(error: error.toString()),
                              loading: () => const Loader(),
                            ),
                        IconButton(
                          onPressed: isGuest? () {}:() {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: GridView.builder(
                                      shrinkWrap: true,
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 4),
                                      itemCount: user.awards.length,
                                      itemBuilder: (context, index) {
                                        final award = user.awards[index];
                                        return GestureDetector(
                                          onTap: () => awardPost(ref, award),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Image.asset(
                                                Constants.awards[award]!),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.card_giftcard_outlined),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
