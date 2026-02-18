import '../../core/constants/app_constants.dart';
import '../../models/room.dart';
import '../../models/booking.dart';
import '../../models/guest.dart';
import '../../models/invoice.dart';
import '../../models/payment.dart';
import '../../models/review.dart';
import '../../models/user.dart';

/// Centralized mock data for development.
///
/// All mock data is defined here so it can be easily replaced
/// when the real API is integrated. No hardcoded data in widgets.
abstract final class MockData {
  // ─── Users ───────────────────────────────────────────────────────
  static final User adminUser = User(
    id: 'usr-001',
    name: 'Sarah Mitchell',
    email: 'admin@sapphirestay.com',
    phone: '+1 (555) 100-0001',
    role: UserRole.admin,
    createdAt: DateTime(2024, 1, 1),
  );

  static final User staffUser = User(
    id: 'usr-002',
    name: 'James Rodriguez',
    email: 'staff@sapphirestay.com',
    phone: '+1 (555) 100-0002',
    role: UserRole.staff,
    createdAt: DateTime(2024, 3, 15),
  );

  static final List<User> staffList = [
    staffUser,
    User(
      id: 'usr-003',
      name: 'Emily Chen',
      email: 'emily@sapphirestay.com',
      phone: '+1 (555) 100-0003',
      role: UserRole.staff,
      createdAt: DateTime(2024, 5, 10),
    ),
    User(
      id: 'usr-004',
      name: 'Michael Okafor',
      email: 'michael@sapphirestay.com',
      phone: '+1 (555) 100-0004',
      role: UserRole.staff,
      createdAt: DateTime(2024, 7, 20),
    ),
  ];

  // ─── Rooms ───────────────────────────────────────────────────────
  static final List<Room> rooms = [
    Room(
      id: 'room-001',
      number: '101',
      type: RoomType.standard,
      name: 'Classic Comfort Room',
      description:
          'A cozy and well-appointed room featuring modern amenities, a plush queen-size bed, and a serene view of the garden courtyard. Perfect for solo travelers or couples seeking comfort.',
      pricePerNight: 120.0,
      capacity: 2,
      floor: 1,
      sizeInSqFt: 320,
      status: RoomStatus.available,
      amenities: ['Wi-Fi', 'Air Conditioning', 'TV', 'Mini Bar', 'Safe', 'Coffee Maker'],
      imageUrls: [AppConstants.roomStandard],
      isFeatured: false,
    ),
    Room(
      id: 'room-002',
      number: '102',
      type: RoomType.standard,
      name: 'Garden View Room',
      description:
          'Enjoy tranquil garden views from this beautifully designed standard room. Features include a comfortable workspace, rain shower, and complimentary breakfast.',
      pricePerNight: 135.0,
      capacity: 2,
      floor: 1,
      sizeInSqFt: 340,
      status: RoomStatus.occupied,
      amenities: ['Wi-Fi', 'Air Conditioning', 'TV', 'Garden View', 'Rain Shower'],
      imageUrls: [AppConstants.roomStandard],
    ),
    Room(
      id: 'room-003',
      number: '201',
      type: RoomType.deluxe,
      name: 'Sapphire Deluxe Room',
      description:
          'Spacious and elegantly furnished, our Deluxe Room offers a king-size bed, premium bath amenities, a lounge area with city views, and access to the executive lounge.',
      pricePerNight: 220.0,
      capacity: 3,
      floor: 2,
      sizeInSqFt: 480,
      status: RoomStatus.available,
      amenities: [
        'Wi-Fi', 'Air Conditioning', 'TV', 'Mini Bar', 'Bathrobe',
        'City View', 'Lounge Access', 'King Bed'
      ],
      imageUrls: [AppConstants.roomDeluxe],
      isFeatured: true,
    ),
    Room(
      id: 'room-004',
      number: '202',
      type: RoomType.deluxe,
      name: 'Ocean Breeze Deluxe',
      description:
          'Wake up to stunning ocean views in this premium deluxe room. Features a private balcony, premium linens, and a luxurious marble bathroom.',
      pricePerNight: 280.0,
      capacity: 3,
      floor: 2,
      sizeInSqFt: 520,
      status: RoomStatus.reserved,
      amenities: [
        'Wi-Fi', 'Air Conditioning', 'TV', 'Mini Bar', 'Balcony',
        'Ocean View', 'Marble Bathroom', 'King Bed'
      ],
      imageUrls: [AppConstants.roomDeluxe],
      isFeatured: true,
    ),
    Room(
      id: 'room-005',
      number: '301',
      type: RoomType.suite,
      name: 'Sapphire Suite',
      description:
          'Our signature suite features a separate living area, dining space, premium entertainment system, walk-in closet, and panoramic city views. Includes butler service.',
      pricePerNight: 450.0,
      capacity: 4,
      floor: 3,
      sizeInSqFt: 780,
      status: RoomStatus.available,
      amenities: [
        'Wi-Fi', 'Air Conditioning', 'Smart TV', 'Mini Bar', 'Living Room',
        'Dining Area', 'Butler Service', 'Walk-in Closet', 'Panoramic View'
      ],
      imageUrls: [AppConstants.roomSuite],
      isFeatured: true,
    ),
    Room(
      id: 'room-006',
      number: '401',
      type: RoomType.presidential,
      name: 'Presidential Suite',
      description:
          'The pinnacle of luxury at Sapphire Stay. This expansive suite spans the entire floor with a master bedroom, private office, full kitchen, grand living area, and exclusive rooftop terrace.',
      pricePerNight: 850.0,
      capacity: 6,
      floor: 4,
      sizeInSqFt: 1500,
      status: RoomStatus.available,
      amenities: [
        'Wi-Fi', 'Air Conditioning', 'Smart TV', 'Full Kitchen', 'Private Office',
        'Grand Living Area', 'Rooftop Terrace', 'Jacuzzi', 'Butler Service',
        'Limousine Transfer', 'Personal Concierge'
      ],
      imageUrls: [AppConstants.roomPresidential],
      isFeatured: true,
    ),
  ];

  // ─── Bookings ────────────────────────────────────────────────────
  static final List<Booking> bookings = [
    Booking(
      id: 'bk-001',
      guestName: 'John Anderson',
      guestEmail: 'john@email.com',
      guestPhone: '+1 (555) 200-0001',
      roomId: 'room-003',
      roomNumber: '201',
      roomType: 'Deluxe',
      checkIn: DateTime(2026, 2, 10),
      checkOut: DateTime(2026, 2, 14),
      guests: 2,
      totalAmount: 880.0,
      status: BookingStatus.confirmed,
      createdAt: DateTime(2026, 2, 1),
    ),
    Booking(
      id: 'bk-002',
      guestName: 'Maria Santos',
      guestEmail: 'maria@email.com',
      guestPhone: '+1 (555) 200-0002',
      roomId: 'room-005',
      roomNumber: '301',
      roomType: 'Suite',
      checkIn: DateTime(2026, 2, 9),
      checkOut: DateTime(2026, 2, 12),
      guests: 3,
      totalAmount: 1350.0,
      status: BookingStatus.checkedIn,
      specialRequests: 'Extra pillows and late checkout',
      createdAt: DateTime(2026, 1, 28),
    ),
    Booking(
      id: 'bk-003',
      guestName: 'David Kim',
      guestEmail: 'david@email.com',
      guestPhone: '+1 (555) 200-0003',
      roomId: 'room-001',
      roomNumber: '101',
      roomType: 'Standard',
      checkIn: DateTime(2026, 2, 15),
      checkOut: DateTime(2026, 2, 17),
      guests: 1,
      totalAmount: 240.0,
      status: BookingStatus.pending,
      createdAt: DateTime(2026, 2, 8),
    ),
    Booking(
      id: 'bk-004',
      guestName: 'Sophie Laurent',
      guestEmail: 'sophie@email.com',
      guestPhone: '+1 (555) 200-0004',
      roomId: 'room-006',
      roomNumber: '401',
      roomType: 'Presidential',
      checkIn: DateTime(2026, 2, 20),
      checkOut: DateTime(2026, 2, 25),
      guests: 4,
      totalAmount: 4250.0,
      status: BookingStatus.confirmed,
      specialRequests: 'Anniversary celebration, champagne on arrival',
      createdAt: DateTime(2026, 2, 5),
    ),
    Booking(
      id: 'bk-005',
      guestName: 'Ahmed Hassan',
      guestEmail: 'ahmed@email.com',
      guestPhone: '+1 (555) 200-0005',
      roomId: 'room-004',
      roomNumber: '202',
      roomType: 'Deluxe',
      checkIn: DateTime(2026, 2, 7),
      checkOut: DateTime(2026, 2, 9),
      guests: 2,
      totalAmount: 560.0,
      status: BookingStatus.completed,
      createdAt: DateTime(2026, 2, 1),
    ),
  ];

  // ─── Guests ──────────────────────────────────────────────────────
  static final List<Guest> guests = [
    Guest(
      id: 'gst-001',
      name: 'John Anderson',
      email: 'john@email.com',
      phone: '+1 (555) 200-0001',
      nationality: 'United States',
      totalStays: 3,
      createdAt: DateTime(2025, 6, 15),
    ),
    Guest(
      id: 'gst-002',
      name: 'Maria Santos',
      email: 'maria@email.com',
      phone: '+1 (555) 200-0002',
      nationality: 'Brazil',
      totalStays: 1,
      createdAt: DateTime(2026, 1, 28),
    ),
    Guest(
      id: 'gst-003',
      name: 'David Kim',
      email: 'david@email.com',
      phone: '+1 (555) 200-0003',
      nationality: 'South Korea',
      totalStays: 5,
      createdAt: DateTime(2024, 11, 1),
    ),
    Guest(
      id: 'gst-004',
      name: 'Sophie Laurent',
      email: 'sophie@email.com',
      phone: '+1 (555) 200-0004',
      nationality: 'France',
      totalStays: 2,
      createdAt: DateTime(2025, 8, 20),
    ),
  ];

  // ─── Invoices ────────────────────────────────────────────────────
  static final List<Invoice> invoices = [
    Invoice(
      id: 'inv-001',
      bookingId: 'bk-005',
      guestName: 'Ahmed Hassan',
      roomNumber: '202',
      issueDate: DateTime(2026, 2, 9),
      subtotal: 560.0,
      tax: 56.0,
      total: 616.0,
      status: InvoiceStatus.paid,
      lineItems: [
        const InvoiceLineItem(
          description: 'Deluxe Room (2 nights)',
          quantity: 2,
          unitPrice: 280.0,
          total: 560.0,
        ),
      ],
    ),
    Invoice(
      id: 'inv-002',
      bookingId: 'bk-002',
      guestName: 'Maria Santos',
      roomNumber: '301',
      issueDate: DateTime(2026, 2, 9),
      subtotal: 1350.0,
      tax: 135.0,
      total: 1485.0,
      status: InvoiceStatus.issued,
      lineItems: [
        const InvoiceLineItem(
          description: 'Suite (3 nights)',
          quantity: 3,
          unitPrice: 450.0,
          total: 1350.0,
        ),
      ],
    ),
  ];

  // ─── Payments ────────────────────────────────────────────────────
  static final List<Payment> payments = [
    Payment(
      id: 'pay-001',
      invoiceId: 'inv-001',
      bookingId: 'bk-005',
      guestName: 'Ahmed Hassan',
      amount: 616.0,
      method: PaymentMethod.creditCard,
      status: PaymentStatus.completed,
      paidAt: DateTime(2026, 2, 9),
      transactionRef: 'TXN-2026-001',
    ),
  ];

  // ─── Reviews ─────────────────────────────────────────────────────
  static final List<Review> reviews = [
    Review(
      id: 'rev-001',
      guestName: 'John Anderson',
      rating: 4.5,
      comment:
          'Exceptional service and stunning rooms. The staff went above and beyond to make our stay memorable. The ocean view from the deluxe room was breathtaking.',
      createdAt: DateTime(2025, 12, 20),
    ),
    Review(
      id: 'rev-002',
      guestName: 'Lisa Wang',
      rating: 5.0,
      comment:
          'Best hotel experience ever! The presidential suite was absolutely incredible. Every detail was perfect, from the welcome champagne to the personal concierge service.',
      createdAt: DateTime(2026, 1, 5),
    ),
    Review(
      id: 'rev-003',
      guestName: 'Robert Mueller',
      rating: 4.0,
      comment:
          'Very comfortable stay. The rooms are clean and well-maintained. The restaurant serves excellent food. Would definitely recommend for business travelers.',
      createdAt: DateTime(2026, 1, 15),
    ),
    Review(
      id: 'rev-004',
      guestName: 'Priya Sharma',
      rating: 4.8,
      comment:
          'A gem of a hotel! The spa facilities are world-class, and the pool area is simply beautiful. The staff remembers your preferences — truly personalized service.',
      createdAt: DateTime(2026, 1, 25),
    ),
  ];

  // ─── Gallery Images ──────────────────────────────────────────────
  static final List<Map<String, String>> galleryImages = [
    {'url': AppConstants.hotelExterior, 'caption': 'Hotel Exterior'},
    {'url': AppConstants.hotelLobby, 'caption': 'Grand Lobby'},
    {'url': AppConstants.hotelPool, 'caption': 'Infinity Pool'},
    {'url': AppConstants.hotelRestaurant, 'caption': 'Fine Dining Restaurant'},
    {'url': AppConstants.hotelSpa, 'caption': 'Spa & Wellness Center'},
    {'url': AppConstants.roomStandard, 'caption': 'Standard Room'},
    {'url': AppConstants.roomDeluxe, 'caption': 'Deluxe Room'},
    {'url': AppConstants.roomSuite, 'caption': 'Sapphire Suite'},
    {'url': AppConstants.roomPresidential, 'caption': 'Presidential Suite'},
  ];

  // ─── Hotel Services ──────────────────────────────────────────────
  static final List<Map<String, dynamic>> hotelServices = [
    {
      'icon': 'restaurant',
      'title': 'Fine Dining',
      'description': 'Award-winning restaurant featuring international cuisine prepared by renowned chefs. Open for breakfast, lunch, and dinner.',
    },
    {
      'icon': 'spa',
      'title': 'Spa & Wellness',
      'description': 'Full-service spa offering massages, facials, body treatments, and a state-of-the-art fitness center.',
    },
    {
      'icon': 'pool',
      'title': 'Swimming Pool',
      'description': 'Heated infinity pool with panoramic ocean views, poolside bar, and dedicated cabanas.',
    },
    {
      'icon': 'business',
      'title': 'Business Center',
      'description': 'Fully equipped business center with meeting rooms, conference facilities, and high-speed internet.',
    },
    {
      'icon': 'car',
      'title': 'Valet Parking',
      'description': 'Complimentary valet parking for all guests. Airport shuttle service available upon request.',
    },
    {
      'icon': 'room_service',
      'title': '24/7 Room Service',
      'description': 'Round-the-clock in-room dining with an extensive menu. Special dietary requirements accommodated.',
    },
    {
      'icon': 'laundry',
      'title': 'Laundry Service',
      'description': 'Same-day laundry and dry cleaning service. Express service available for urgent needs.',
    },
    {
      'icon': 'concierge',
      'title': 'Concierge',
      'description': 'Expert concierge team to assist with tour bookings, restaurant reservations, and local recommendations.',
    },
  ];
}
