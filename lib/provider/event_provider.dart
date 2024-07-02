import 'package:flutter/material.dart';
import 'package:student_welbeing/models/event_model.dart';

class EventProvider extends ChangeNotifier {
  List<Event> _events = []; // List to hold events

  // Method to update events
  void updateEvents(List<Event> events) {
    _events = events;
    notifyListeners(); // Notify listeners of changes
  }

  // Getter to access events
  List<Event> get events => _events;
}
