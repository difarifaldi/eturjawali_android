import 'dart:convert';

import 'package:eturjawali_android/models/giat_media.dart';
import 'package:eturjawali_android/models/partner.dart';
import 'package:eturjawali_android/models/route.dart';

class Giat {
  final String id;
  final String name;
  final String userName;
  final int userId;
  final String? saveDate;
  final String? startDate;
  final String? endDate;
  final int sprintId;
  final String? desc;
  final int fileCount;
  final String? sprintNo;
  final String? workingUnitName;
  final String? workingUnitId;
  final int status;
  final String? param1;
  final String? param2;
  final String? param3;
  final String? param4;
  final String? param5;
  final String? param6;
  final String? param7;
  final String? param8;
  final String? param9;
  final String? param10;
  final String? latitude;
  final String? longitude;
  final String? address;
  final String? time;
  final bool syncStatus;
  final String? giatStatus;
  final int reportId;
  final String localId;
  final List<GiatMedia> files;
  final List<Partner> partner;
  final String? lambungNo;
  final List<RouteModel> route;

  Giat({
    required this.id,
    required this.name,
    required this.userName,
    required this.userId,
    this.saveDate,
    this.startDate,
    this.endDate,
    required this.sprintId,
    this.desc,
    required this.fileCount,
    this.sprintNo,
    this.workingUnitName,
    this.workingUnitId,
    required this.status,
    this.param1,
    this.param2,
    this.param3,
    this.param4,
    this.param5,
    this.param6,
    this.param7,
    this.param8,
    this.param9,
    this.param10,
    this.latitude,
    this.longitude,
    this.address,
    this.time,
    required this.syncStatus,
    this.giatStatus,
    required this.reportId,
    required this.localId,
    required this.files,
    required this.partner,
    this.lambungNo,
    required this.route,
  });

  factory Giat.fromJson(Map<String, dynamic> json) {
    return Giat(
      id: json['id_kegiatan'] ?? '',
      name: json['jenis'] ?? '',
      userName: json['nama_petugas'] ?? '',
      userId: int.tryParse(json['id_petugas'].toString()) ?? 0,
      saveDate: json['waktu_simpan'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      sprintId: int.tryParse(json['id_sprin'].toString()) ?? 0,
      desc: json['catatan'],
      fileCount: int.tryParse(json['jumlah_file']?.toString() ?? '0') ?? 0,
      sprintNo: json['nomor_sprin'],
      workingUnitName: json['nama_kesatuan'],
      workingUnitId: json['id_kesatuan'],
      status: int.tryParse(json['status'].toString()) ?? 0,
      param1: json['param1'],
      param2: json['param2'],
      param3: json['param3'],
      param4: json['param4'],
      param5: json['param5'],
      param6: json['param6'],
      param7: json['param7'],
      param8: json['param8'],
      param9: json['param9'],
      param10: json['param10'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['lokasi'],
      time: json['waktu_simpan'],
      syncStatus:
          json['waktu_simpan'] != null &&
          (json['waktu_simpan'] as String).isNotEmpty,
      giatStatus: json['giatStatus'],
      reportId: int.tryParse(json['reportId']?.toString() ?? '0') ?? 0,
      localId: json['id_lokal'] ?? '',
      files:
          (json['files'] as List<dynamic>?)
              ?.map((e) => GiatMedia.fromJson(e))
              .toList() ??
          [],
      partner:
          (json['rekan'] as List<dynamic>?)
              ?.map((e) => Partner.fromJson(e))
              .toList() ??
          [],
      lambungNo: json['no_lambung'],
      route:
          (json['rute'] as List<dynamic>?)
              ?.map((e) => RouteModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
