/// A function type definition for event listeners.
///
/// Event listeners receive dynamic data when an event is posted.
typedef EventListener = void Function(dynamic data);

/// A simple event bus implementation for managing and dispatching events.
///
/// The [Event] class provides a publish-subscribe pattern, allowing
/// components to register listeners for specific event types and post
/// events that trigger those listeners.
class Emitter {
  /// Internal map storing event types and their associated listeners.
  final Map<dynamic, List<EventListener>> _eventMap = {};

  /// Adds an event listener for a specific event type.
  ///
  /// The [type] parameter identifies the event type to listen for.
  /// The [listener] parameter is the callback function to be invoked
  /// when an event of this type is posted.
  ///
  /// Multiple listeners can be registered for the same event type.
  void add(dynamic type, EventListener listener) {
    if (_eventMap.containsKey(type)) {
      _eventMap[type]?.add(listener);
    } else {
      _eventMap[type] = [listener];
    }
  }

  /// Removes a specific event listener for a given event type.
  ///
  /// The [type] parameter identifies the event type.
  /// The [listener] parameter is the specific listener to remove.
  void remove(dynamic type, EventListener listener) {
    _eventMap[type]?.remove(listener);
  }

  /// Posts an event to all registered listeners for the specified type.
  ///
  /// The [type] parameter identifies the event type to post.
  /// The [data] parameter contains the event data to be passed to all listeners.
  ///
  /// If no listeners are registered for the given type, this method returns immediately.
  void post(dynamic type, dynamic data) {
    if (!_eventMap.containsKey(type)) return;
    for (final element in _eventMap[type]!) {
      element.call(data);
    }
  }
}
