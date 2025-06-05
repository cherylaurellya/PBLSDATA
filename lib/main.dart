import 'dart:io';

// Data structures implementation
class Vehicle {
  String plateNumber;
  String type;
  DateTime entryTime;
  String location;

  Vehicle(this.plateNumber, this.type, [this.location = 'A']) : entryTime = DateTime.now();
}

class Node<T> {
  T data;
  Node<T>? next;

  Node(this.data);
}

class LinkedList<T> {
  Node<T>? head;

  void add(T data) {
    Node<T> newNode = Node(data);
    if (head == null) {
      head = newNode;
    } else {
      Node<T>? current = head;
      while (current?.next != null) {
        current = current?.next;
      }
      current?.next = newNode;
    }
  }

  List<T> toList() {
    List<T> result = [];
    Node<T>? current = head;
    while (current != null) {
      result.add(current.data);
      current = current.next;
    }
    return result;
  }
}

class Queue<T> {
  List<T> _items = [];

  void enqueue(T item) => _items.add(item);
  T? dequeue() => _items.isNotEmpty ? _items.removeAt(0) : null;
  bool get isEmpty => _items.isEmpty;
  List<T> toList() => List.from(_items);
  int get length => _items.length;
}

class ParkingSystem {
  final int capacity;
  Map<String, Vehicle> parkedVehicles = {};
  Queue<Vehicle> waitingVehicles = Queue<Vehicle>();
  LinkedList<Vehicle> parkingHistory = LinkedList<Vehicle>();
  Map<String, int> locationCapacity = {
    'A': 2,
    'B': 2,
    'C': 1,
  };

  ParkingSystem(this.capacity);

  bool parkVehicle(Vehicle vehicle) {
    if (!locationCapacity.containsKey(vehicle.location)) {
      print('Invalid parking location: ${vehicle.location}');
      return false;
    }

    if (parkedVehicles.containsKey(vehicle.plateNumber)) {
      print('Vehicle with plate number ${vehicle.plateNumber} is already parked!');
      return false;
    }

    int currentLocationCount = parkedVehicles.values
        .where((v) => v.location == vehicle.location)
        .length;

    if (currentLocationCount >= locationCapacity[vehicle.location]!) {
      print('Parking area ${vehicle.location} is full!');
      print('Adding vehicle to waiting queue...');
      waitingVehicles.enqueue(vehicle);
      return false;
    }

    parkedVehicles[vehicle.plateNumber] = vehicle;
    parkingHistory.add(vehicle);
    print('Vehicle with plate number ${vehicle.plateNumber} (${vehicle.type}) parked at location ${vehicle.location}.');
    return true;
  }

  Vehicle? removeVehicle(String plateNumber) {
    Vehicle? vehicle = parkedVehicles.remove(plateNumber);
    if (vehicle != null && !waitingVehicles.isEmpty) {
      Vehicle? waitingVehicle = waitingVehicles.dequeue();
      if (waitingVehicle != null) {
        parkedVehicles[waitingVehicle.plateNumber] = waitingVehicle;
        print('Vehicle with plate number ${waitingVehicle.plateNumber} (${waitingVehicle.type}) moved from waiting queue to location ${waitingVehicle.location}.');
      }
    }
    return vehicle;
  }

  bool changeVehicleLocation(String plateNumber, String newLocation) {
    if (!locationCapacity.containsKey(newLocation)) {
      print('Invalid location!');
      return false;
    }

    Vehicle? vehicle = parkedVehicles[plateNumber];
    if (vehicle == null) {
      print('Vehicle not found!');
      return false;
    }

    int currentLocationCount = parkedVehicles.values
        .where((v) => v.location == newLocation)
        .length;

    if (currentLocationCount >= locationCapacity[newLocation]!) {
      print('New location $newLocation is full!');
      return false;
    }

    vehicle.location = newLocation;
    return true;
  }

  List<Vehicle> searchVehiclesByType(String type) {
    return parkedVehicles.values
        .where((vehicle) => vehicle.type.toLowerCase() == type.toLowerCase())
        .toList();
  }

  void displayParkedVehicles() {
    if (parkedVehicles.isEmpty) {
      print('No vehicles currently parked.');
      return;
    }

    print('\nCurrently parked vehicles:');
    print('Total vehicles: ${parkedVehicles.length}');
    
    // Display capacity information
    print('\nParking Capacity:');
    locationCapacity.forEach((loc, cap) {
      int used = parkedVehicles.values.where((v) => v.location == loc).length;
      print('Location $loc: $used $cap used');
    });

    print('\nVehicle Details:');
    print('=' * 65);
    print('Plate No.   | Type     | Location | Entry Time');
    print('-' * 65);
    
    List<Vehicle> sortedVehicles = parkedVehicles.values.toList()
      ..sort((a, b) => a.plateNumber.compareTo(b.plateNumber));

    for (var vehicle in sortedVehicles) {
      String time = '${vehicle.entryTime.hour.toString().padLeft(2, '0')}:${vehicle.entryTime.minute.toString().padLeft(2, '0')}';
      print('${vehicle.plateNumber.padRight(11)}| ${vehicle.type.padRight(9)}| ${vehicle.location.padRight(9)}| $time');
    } 

    if (!waitingVehicles.isEmpty) {
      print('\nVehicles in waiting queue: ${waitingVehicles.length}');
    }
  }
}

void main() {
  ParkingSystem parkingSystem = ParkingSystem(5);

  while (true) {
    print('\n=== Parking System Menu ===');
    print('1. Park Vehicle');
    print('2. Remove Vehicle');
    print('3. Display Parking Status');
    print('4. Change Parking Location');
    print('5. Search Vehicles by Type');
    print('6. Display Waiting');
    print('7. Exit');
    print('========================');

    stdout.write('Enter your choice: ');
    String? choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        stdout.write('Enter plate number: ');
        String? plate = stdin.readLineSync();
        stdout.write('Enter vehicle type: ');
        String? type = stdin.readLineSync();
        stdout.write('Enter parking location (A/B/C): ');
        String? location = stdin.readLineSync();
        if (plate != null && type != null && location != null) {
          Vehicle vehicle = Vehicle(plate, type, location);
          bool parked = parkingSystem.parkVehicle(vehicle);
          if (parked) {
            print('Vehicle parked successfully!');
          } else {
            print('Parking failed. Vehicle added to waiting queue.');
          }
        }
        break;

      case '2':
        stdout.write('Enter plate number to remove: ');
        String? plate = stdin.readLineSync();
        if (plate != null) {
          Vehicle? removed = parkingSystem.removeVehicle(plate);
          if (removed != null) {
            print('Vehicle removed successfully!');
          } else {
            print('Vehicle not found!');
          }
        }
        break;

      case '3':
        parkingSystem.displayParkedVehicles();
        break;

      case '4':
        stdout.write('Enter plate number: ');
        String? plate = stdin.readLineSync();
        stdout.write('Enter new location (A/B/C): ');
        String? location = stdin.readLineSync();
        if (plate != null && location != null) {
          bool changed = parkingSystem.changeVehicleLocation(plate, location);
          if (changed) {
            print('Parking location changed successfully!');
          }
        }
        break;

      case '5':
        stdout.write('Enter vehicle type to search: ');
        String? type = stdin.readLineSync();
        if (type != null) {
          List<Vehicle> found = parkingSystem.searchVehiclesByType(type);
          if (found.isEmpty) {
            print('No vehicles found of type: $type');
          } else {
            print('\nFound vehicles:');
            for (var vehicle in found) {
              print('Plate: ${vehicle.plateNumber}, Type: ${vehicle.type}, Location: ${vehicle.location}');
            }
          }
        }
        break;

      case '6':
        if (parkingSystem.waitingVehicles.isEmpty) {
          print('No vehicles in waiting queue.');
        } else {
          print('\nVehicles in waiting queue:');
          print('=' * 65);
          print('Plate No.   | Type     | Requested Location');
          print('-' * 65);
          List<Vehicle> queueList = parkingSystem.waitingVehicles.toList(); 
          for (var vehicle in queueList) {
            print('${vehicle.plateNumber.padRight(11)}| ${vehicle.type.padRight(9)}| ${vehicle.location}');
          }
        }
        break;

      case '7':
        print('Thank you for using the Parking System!');
        return;

      default:
        print('Invalid choice. Please try again.');
    }
  }
}