import 'package:flutter/material.dart';
import 'package:tutoring/constants/subjects.dart';

class SubjectPicker extends StatefulWidget {
  final Function(String) onSubectSelected;
  final String? initialSubject;

  const SubjectPicker({
    super.key,
    required this.onSubectSelected,
    this.initialSubject,
  });

  @override
  _SubjectPickerState createState() => _SubjectPickerState();
}

class _SubjectPickerState extends State<SubjectPicker> {
  final List<String> subects = Subjects.allSubjects;

  String? _selectedSubject;

  @override
  void initState() {
    super.initState();
    _selectedSubject = widget.initialSubject;
  }

  void _showSubjectPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Konu Seçin',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: subects.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(subects[index]),
                      onTap: () {
                        setState(() {
                          _selectedSubject = subects[index];
                        });
                        widget.onSubectSelected(subects[index]);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showSubjectPicker(context),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedSubject ?? 'Konu Seçiniz',
                  style: TextStyle(
                    color:
                        _selectedSubject == null ? Colors.grey : Colors.black,
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
