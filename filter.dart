Map data = {
  'channel_id': 49281,
  'feeds': [
    {'created_at': '2023-01-11T10:03:24Z', 'field4': 5},
    {'created_at': '2023-01-11T10:03:24Z', 'field1': 40.762955},
    {'created_at': '2023-01-11T10:03:24Z', 'field3': 4.37},
    {'created_at': '2023-01-11T10:03:24Z', 'field2': 23},
    {'created_at': '2023-01-11T10:03:29Z', 'field5': -65},
  ],
};

Map d = {
  "channel_id": 49281,
  "feeds": [   {"field4": 5},
    {"field1": 40.762955},
    {"field3": 4.37},
    {"field2": 23},
    {"field5": -65}
  ]
};

void main() {
  print(data['feeds'][2]['field1']);
}
