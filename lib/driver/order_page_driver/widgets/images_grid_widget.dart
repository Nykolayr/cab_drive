import '/backend/api/file_storage_service.dart';
import '/pages/bottom/image_view/image_view_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/backend/backend.dart';
import 'package:flutter/material.dart';

// Images grid widget (shows cargo photos)
class ImagesGridWidget extends StatelessWidget {
  const ImagesGridWidget({
    super.key,
    required this.order, this.onUpdate,
  });

  final Function()? onUpdate;
  final OrderRecord order;

  @override
  Widget build(BuildContext context) {
    if (order.images.isEmpty) return SizedBox.shrink();
    final imagesCargo = order.images.toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: FlutterFlowTheme.of(context).secondaryBackground, borderRadius: BorderRadius.circular(18.0)),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Фото груза', style: FlutterFlowTheme.of(context).bodyMedium.override(fontFamily: 'SF', color: FlutterFlowTheme.of(context).secondaryText, fontSize: 16.0, fontWeight: FontWeight.w500)),
            SizedBox(height: 12.0),
            GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, crossAxisSpacing: 6.0, mainAxisSpacing: 6.0, childAspectRatio: 1.0),
              primary: false,
              shrinkWrap: true,
              itemCount: imagesCargo.length,
              itemBuilder: (context, index) {
                final item = imagesCargo[index];
                return InkWell(
                  onTap: () async {
                    await showModalBottomSheet(
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) {
                        return GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          child: Padding(
                            padding: MediaQuery.viewInsetsOf(context),
                            child: ImageViewWidget(indexCurrent: index, alllistImage: order.images),
                          ),
                        );
                      },
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.network(FileStorageService.getImageUrl(item), width: double.infinity, height: 120.0, fit: BoxFit.cover),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}