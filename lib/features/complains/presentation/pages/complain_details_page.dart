import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/theme/app_color.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';
import 'package:medizen_app/features/complains/data/models/complain_model.dart';
import 'package:medizen_app/main.dart';

import '../cubit/complain_cubit/complain_cubit.dart';

class ComplainDetailsPage extends StatefulWidget {
  final String complainId;

  const ComplainDetailsPage({super.key, required this.complainId});

  @override
  _ComplainDetailsPageState createState() => _ComplainDetailsPageState();
}

class _ComplainDetailsPageState extends State<ComplainDetailsPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _responseController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isSending = false;
  ComplainModel? _currentComplain;
  List<XFile> _attachments = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    context.read<ComplainCubit>().getComplainDetails(
      context: context,
      complainId: widget.complainId,
    );
    _loadResponses();
  }

  void _loadResponses() {
    context.read<ComplainCubit>().getComplainResponses(
      complainId: widget.complainId,
      context: context,
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage(
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      if (images != null && images.isNotEmpty) {
        setState(() {
          _attachments.addAll(images);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('complaintDetailsPage.failedToPickImages'.tr(context)),
        ),
      );
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  void _confirmCloseComplain() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(
              'complaintDetailsPage.closeComplaintDialogTitle'.tr(context),
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            content: Text(
              'complaintDetailsPage.closeComplaintDialogContent'.tr(context),
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'complaintDetailsPage.cancelButton'.tr(context),
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.read<ComplainCubit>().closeComplain(
                    complainId: widget.complainId,
                    context: context,
                  );
                },
                child: Text(
                  'complaintDetailsPage.closeButton'.tr(context),
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _responseController.dispose();
    super.dispose();
  }

  bool isClose = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'complaintDetailsPage.complaintDetailsPageTitle'.tr(context),
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.primaryColor),
            onPressed: _loadInitialData,
          ),
        ],
      ),
      body: BlocConsumer<ComplainCubit, ComplainState>(
        listener: (context, state) {
          if (state is ComplainError) {
          ShowToast.showToastError(message: state.error);
            setState(() => _isSending = false);
          } else if (state is ComplainActionSuccess) {
           ShowToast.showToastError(message: state.message);
            _responseController.clear();
            setState(() {
              _isSending = false;
              _attachments.clear();
            });
            _loadResponses();
          } else if (state is ComplainDetailsSuccess) {
            setState(() => _currentComplain = state.complain);
          }
        },
        builder: (context, state) {
          if (_currentComplain != null) {
            return _buildChatInterface(_currentComplain!, isDarkMode);
          } else if (state is ComplainLoading) {
            return const Center(child: LoadingPage());
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'complaintDetailsPage.failedToLoadComplaint'.tr(context),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadInitialData,
                    child: Text('complaintDetailsPage.retryButton'.tr(context)),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildChatInterface(ComplainModel complain, bool isDarkMode) {
    isClose = complain.status?.code == 'complaint_closed';

    return Column(
      children: [
        GestureDetector(
          onTap:
              complain.status?.code == "complaint_closed"
                  ? null
                  : _confirmCloseComplain,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: _getStatusColor(
              complain.status?.code,
            ).withOpacity(isDarkMode ? 0.3 : 0.2),
            child: Center(
              child: Text(
                complain.status?.display ??
                    'complaintDetailsPage.noStatus'.tr(context),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(complain.status?.code),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: BlocBuilder<ComplainCubit, ComplainState>(
            buildWhen:
                (previous, current) =>
                    current is ComplainResponsesSuccess ||
                    current is ComplainLoading,
            builder: (context, state) {
              if (state is ComplainResponsesSuccess) {
                final allMessages = _combineAndSortMessages(
                  complain,
                  state.responses,
                );
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: allMessages.length,
                  itemBuilder: (context, index) {
                    final message = allMessages[index];
                    return _buildMessageBubble(
                      message: message.response ?? '',
                      isMe: message.isFromUser,
                      sender: message.senderName,
                      time: message.createdAt,
                      isDarkMode: isDarkMode,
                      attachments: message.attachmentsUrl,
                    );
                  },
                );
              }
              return const Center(child: LoadingPage());
            },
          ),
        ),
        if (!isClose) ...[
          if (_attachments.isNotEmpty) _buildAttachmentsPreview(isDarkMode),
          _buildInputArea(isDarkMode),
        ] else
          _buildClosedComplaintMessage(isDarkMode),
      ],
    );
  }

  Widget _buildClosedComplaintMessage(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: isDarkMode ? Colors.grey[900] : Colors.grey[200],
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'complaintDetailsPage.thisComplaintIsClosed'.tr(context),
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    );
  }

  List<_MessageItem> _combineAndSortMessages(
    ComplainModel complain,
    List<ComplainResponseModel> responses,
  ) {
    final allMessages = <_MessageItem>[
      _MessageItem(
        response: complain.description,
        createdAt: complain.createdAt ?? DateTime.now(),
        isFromUser: true,
        senderName: 'complaintDetailsPage.youSender'.tr(context),
        attachmentsUrl: complain.attachmentsUrl ?? [],
      ),
      ...responses.map(
        (r) => _MessageItem(
          response: r.response,
          createdAt: r.createdAt!,
          isFromUser: r.sender?.id == loadingPatientModel().id,
          senderName:
              r.sender?.fName ?? 'complaintDetailsPage.staffSender'.tr(context),
          attachmentsUrl: r.attachmentsUrl ?? [],
        ),
      ),
    ];
    allMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return allMessages;
  }

  Widget _buildAttachmentsPreview(bool isDarkMode) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _attachments.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: FileImage(File(_attachments[index].path)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => _removeAttachment(index),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble({
    required String message,
    required bool isMe,
    required String sender,
    required DateTime time,
    bool isFirstMessage = false,
    required bool isDarkMode,
    required List<ComplaintResponseAttachment> attachments,
  }) {
    final bubbleColor =
        isMe
            ? (isDarkMode
                ? AppColors.backGroundLogo
                : Theme.of(context).primaryColor)
            : (isDarkMode ? Colors.grey[800]! : Colors.grey[200]!);

    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMe)
                      Text(
                        sender,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: textColor,
                        ),
                      ),
                    if (message.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          message,
                          style: TextStyle(color: textColor),
                        ),
                      ),
                    if (attachments.isNotEmpty)
                      Column(
                        children:
                            attachments
                                .map(
                                  (attachment) => Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Image.network(
                                      attachment.fileUrl,
                                      width: 200,
                                      height: 150,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (
                                        context,
                                        child,
                                        loadingProgress,
                                      ) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          width: 200,
                                          height: 150,
                                          color: Colors.grey[300],
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                width: 200,
                                                height: 150,
                                                color: Colors.grey[300],
                                                child: const Icon(
                                                  Icons.broken_image,
                                                ),
                                              ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  DateFormat('MMM d, y hh:mm a').format(time),
                  style: TextStyle(
                    fontSize: 10,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(isDarkMode ? 0.1 : 0.2),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.attach_file,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: _pickImages,
              ),
              Expanded(
                child: TextField(
                  controller: _responseController,
                  decoration: InputDecoration(
                    hintText: 'complaintDetailsPage.typeYourResponseHint'.tr(
                      context,
                    ),
                    hintStyle: TextStyle(
                      color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  maxLines: 3,
                  minLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              _isSending
                  ? const LoadingPage()
                  : IconButton(
                    icon: Icon(
                      Icons.send,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () {
                      if (_responseController.text.trim().isNotEmpty ||
                          _attachments.isNotEmpty) {
                        setState(() => _isSending = true);
                        context.read<ComplainCubit>().respondToComplain(
                          complainId: widget.complainId,
                          responseText: _responseController.text.trim(),
                          attachments:
                              _attachments
                                  .map((file) => File(file.path))
                                  .toList(),
                          context: context,
                        );
                      }
                    },
                  ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? statusCode) {
    switch (statusCode) {
      case 'complaint_new':
        return Colors.orange;
      case 'complaint_in_review':
        return Colors.blue;
      case 'complaint_resolved':
        return Colors.green;
      case 'complaint_closed':
        return Colors.grey;
      case 'complaint_rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _MessageItem {
  final String? response;
  final DateTime createdAt;
  final bool isFromUser;
  final String senderName;
  final List<ComplaintResponseAttachment> attachmentsUrl;

  _MessageItem({
    required this.response,
    required this.createdAt,
    required this.isFromUser,
    required this.senderName,
    required this.attachmentsUrl,
  });
}
