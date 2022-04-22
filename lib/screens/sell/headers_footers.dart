import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pos_app/provider/headers_footers_provider.dart';
import 'package:pos_app/widgets/special_design.dart';
import 'package:provider/provider.dart';

const String typeHeader = 'typeHeader';
const String typeFooter = 'typeFooter';

class HeadersFooters extends StatefulWidget {
  const HeadersFooters({Key? key, required this.type}) : super(key: key);

  final String type;

  @override
  State<HeadersFooters> createState() => _HeadersFootersState();
}

class _HeadersFootersState extends State<HeadersFooters> {
  final TextEditingController _controller = TextEditingController();

  int id = -1;

  @override
  void initState() {
    Provider.of<HeadersFootersProvider>(context, listen: false).getData();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<HeadersFootersProvider>(context, listen: false);
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.type == typeHeader ? 'Edit Headers' : 'Edit Footers'),
      ),
      body: Column(
        children: [
          Card(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12.0),
                  bottomRight: Radius.circular(12.0),
           topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
              )
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(alignment: Alignment.topLeft,child: Text('Enter ${widget.type == typeHeader ? 'new header' : 'new footer'} text here',style: const TextStyle(fontWeight: FontWeight.w500),)),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    children: [

                      Expanded(
                          child: TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.text,
                        maxLines: 3,
                        maxLength: 22,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder()
                                ),
                      )),
                      Column(
                        children: [
                          IconButton(
                              onPressed: () {
                                _controller.text = '';
                                //id=-1;
                              },
                              icon: const Icon(Icons.clear_all)),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CustomButton(
                              color: Colors.green,
                              child: InkWell(
                                  onTap: () async {
                                    String text = _controller.text.toString();
                                    if (widget.type == typeHeader) {
                                      if (id < 0) {
                                        await Provider.of<HeadersFootersProvider>(context,
                                            listen: false)
                                            .addHeaders(text);
                                      } else {
                                        await Provider.of<HeadersFootersProvider>(context,
                                            listen: false)
                                            .updateHeaders(text, id);
                                      }
                                    } else {
                                      if (id < 0) {
                                        await Provider.of<HeadersFootersProvider>(context,
                                            listen: false)
                                            .addFooters(text);
                                      } else {
                                        await Provider.of<HeadersFootersProvider>(context,
                                            listen: false)
                                            .updateFooters(text, id);
                                      }
                                    }
                                    _controller.text = '';
                                    id = -1;
                                    setState(() {

                                    });
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Icon(Icons.done,color: Colors.white,),
                                  )),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),

                ],
              ),
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
                itemBuilder: (ctx, index) {
                return  Padding(
                  key: Key('$index'),
                  padding: const EdgeInsets.all(2.0),
                  child: Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                              onPressed: () async {
                                if (typeFooter == widget.type) {
                                  await Provider.of<HeadersFootersProvider>(context,
                                      listen: false)
                                      .removeFooters(index);
                                } else {
                                  await Provider.of<HeadersFootersProvider>(context,
                                      listen: false)
                                      .removeHeaders(index);
                                }
                                setState(() {});
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              )),
                          Expanded(
                            child: Text((widget.type == typeHeader)
                                ? data.headers[index]
                                : data.footers[index]),
                          ),
                          IconButton(
                              onPressed: () {
                                _controller.text = (widget.type == typeHeader)
                                    ? data.headers[index]
                                    : data.footers[index];
                                id = index;
                                setState(() {});
                              },
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.green,
                              )),
                        ],
                      ),
                    ),
                  ),
                );


                },
                itemCount: widget.type == typeHeader
                    ? data.headers.length
                    : data.footers.length,
                onReorder: (oldIndex, newIndex) async {


                  if (typeHeader == widget.type) {
                    await Provider.of<HeadersFootersProvider>(context,
                            listen: false)
                        .rearrangeHeaders(oldIndex, newIndex);
                  } else {
                    await Provider.of<HeadersFootersProvider>(context,
                            listen: false)
                        .rearrangeFooters(oldIndex, newIndex);
                  }

                  setState(() {});
                }),
          ),
        ],
      ),
    );
  }
}
