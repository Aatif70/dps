import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dps/constants/api_constants.dart';

class AdminStudentService {
  static Future<List<StudentSearchResult>> searchStudents({required String term}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.searchStudent}');
      final request = http.MultipartRequest('POST', url);
      request.fields['term'] = term;
      request.fields['UId'] = uid;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] is List) {
          final List<dynamic> data = jsonData['data'];
          return data.map((e) => StudentSearchResult.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<StudentBriefDetails?> fetchStudentBriefDetails({required int studentId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';

      final url = Uri.parse('${ApiConstants.baseUrl}/api/User/SearchStudentDetail');
      final request = http.MultipartRequest('POST', url);
      request.fields['StudentId'] = studentId.toString();
      request.fields['UId'] = uid;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] is Map<String, dynamic>) {
          return StudentBriefDetails.fromJson(jsonData['data'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<StudentPersonalDetail?> fetchStudentPersonalDetail({
    required int studentId,
    String addressType = 'Permanent',
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.studentPersonalDetail}');
      final request = http.MultipartRequest('POST', url);
      request.fields['StudentId'] = studentId.toString();
      request.fields['UId'] = uid;
      request.fields['AddressType'] = addressType;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] is Map<String, dynamic>) {
          return StudentPersonalDetail.fromJson(jsonData['data'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<List<GuardianDetail>> fetchGuardianDetails({required int studentId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.guardianDetail}');
      final request = http.MultipartRequest('POST', url);
      request.fields['StudentId'] = studentId.toString();
      request.fields['UId'] = uid;
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] is List) {
          final List<dynamic> data = jsonData['data'];
          return data.map((e) => GuardianDetail.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<List<PreviousSchoolItem>> fetchPreviousSchools({required int studentId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.previousSchool}');
      final request = http.MultipartRequest('POST', url);
      request.fields['StudentId'] = studentId.toString();
      request.fields['UId'] = uid;
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] is List) {
          final List<dynamic> data = jsonData['data'];
          return data.map((e) => PreviousSchoolItem.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<List<BankDetail>> fetchBankDetails({required int studentId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.bankDetail}');
      final request = http.MultipartRequest('POST', url);
      request.fields['StudentId'] = studentId.toString();
      request.fields['UId'] = uid;
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] is List) {
          final List<dynamic> data = jsonData['data'];
          return data.map((e) => BankDetail.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<IncomeDetail?> fetchIncomeDetail({required int studentId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.incomeDetail}');
      final request = http.MultipartRequest('POST', url);
      request.fields['StudentId'] = studentId.toString();
      request.fields['UId'] = uid;
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] is Map<String, dynamic>) {
          return IncomeDetail.fromJson(jsonData['data'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<CasteReligionDetail?> fetchCasteReligionDetail({required int studentId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.casteReligionDetail}');
      final request = http.MultipartRequest('POST', url);
      request.fields['StudentId'] = studentId.toString();
      request.fields['UId'] = uid;
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] is Map<String, dynamic>) {
          return CasteReligionDetail.fromJson(jsonData['data'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<List<DocumentCategory>> fetchStudentDocuments({required int studentId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.studentDocuments}');
      final request = http.MultipartRequest('POST', url);
      request.fields['StudentId'] = studentId.toString();
      request.fields['UId'] = uid;
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] is List) {
          final List<dynamic> data = jsonData['data'];
          return data.map((e) => DocumentCategory.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}

class StudentSearchResult {
  final String name;
  final int id;

  StudentSearchResult({required this.name, required this.id});

  factory StudentSearchResult.fromJson(Map<String, dynamic> json) {
    return StudentSearchResult(
      name: (json['Name'] ?? '').toString(),
      id: (json['ID'] ?? 0) is int ? (json['ID'] as int) : int.tryParse((json['ID'] ?? '0').toString()) ?? 0,
    );
  }
}

class StudentBriefDetails {
  final int studentId;
  final String studentName;
  final String email;
  final String studentClass;
  final int admissionYear;
  final String caste;
  final String category;
  final String photo;
  final String prn;
  final String address;
  final String studentMobile;
  final String parentMobile;

  const StudentBriefDetails({
    required this.studentId,
    required this.studentName,
    required this.email,
    required this.studentClass,
    required this.admissionYear,
    required this.caste,
    required this.category,
    required this.photo,
    required this.prn,
    required this.address,
    required this.studentMobile,
    required this.parentMobile,
  });

  factory StudentBriefDetails.fromJson(Map<String, dynamic> json) {
    return StudentBriefDetails(
      studentId: (json['StudentId'] ?? 0) is int ? json['StudentId'] as int : int.tryParse((json['StudentId'] ?? '0').toString()) ?? 0,
      studentName: (json['StudentName'] ?? '').toString(),
      email: (json['Email'] ?? '').toString(),
      studentClass: (json['Class'] ?? '').toString(),
      admissionYear: (json['AdmissionYear'] ?? 0) is int ? json['AdmissionYear'] as int : int.tryParse((json['AdmissionYear'] ?? '0').toString()) ?? 0,
      caste: (json['Caste'] ?? '').toString(),
      category: (json['Category'] ?? '').toString(),
      photo: (json['Photo'] ?? '').toString(),
      prn: (json['PRN'] ?? '').toString(),
      address: (json['Address'] ?? '').toString(),
      studentMobile: (json['StudentMobile'] ?? '').toString(),
      parentMobile: (json['ParentMobile'] ?? '').toString(),
    );
  }

  String get photoUrl => photo.isNotEmpty ? '${ApiConstants.baseUrl}$photo' : '';
}

class StudentPersonalDetail {
  final int studentId;
  final String studentName;
  final String email;
  final String photo;
  final String studentClass;
  final String category;
  final String academicYear;
  final String gender;
  final String bloodGroup;
  final String nationality;
  final String dateOfBirth; // ISO
  final String placeOfBirth;
  final String aadhaarCardNo;
  final String? panCardNo;
  final String religion;
  final String contactNo;
  final String address;
  final String city;
  final String pincode;
  final String state;
  final String? gaoOrTown;
  final String? district;
  final String? healthInfo;
  final String physicalHandicap;
  final String? physicalHandicapType;
  final bool maharashtraDomicile;
  final String fatherName;
  final String motherName;
  final String fatherContact;
  final String motherContact;
  final String? fatherDOB;
  final String? motherDOB;
  final String? fatherQualification;
  final String? motherQualification;
  final String? fatherDesignation;
  final String? motherDesignation;
  final String? fatherOffice;
  final String? motherOffice;
  final String registrationDate;
  final bool approveForAdmission;
  final String? quota;
  final String? eligibility;
  final String? medium;
  final String? division;
  final String schoolPRN;
  final String admissionCancel;
  final String? admissionCancelDate;
  final String? admissionCancelReason;
  final String? signature;

  const StudentPersonalDetail({
    required this.studentId,
    required this.studentName,
    required this.email,
    required this.photo,
    required this.studentClass,
    required this.category,
    required this.academicYear,
    required this.gender,
    required this.bloodGroup,
    required this.nationality,
    required this.dateOfBirth,
    required this.placeOfBirth,
    required this.aadhaarCardNo,
    required this.panCardNo,
    required this.religion,
    required this.contactNo,
    required this.address,
    required this.city,
    required this.pincode,
    required this.state,
    required this.gaoOrTown,
    required this.district,
    required this.healthInfo,
    required this.physicalHandicap,
    required this.physicalHandicapType,
    required this.maharashtraDomicile,
    required this.fatherName,
    required this.motherName,
    required this.fatherContact,
    required this.motherContact,
    required this.fatherDOB,
    required this.motherDOB,
    required this.fatherQualification,
    required this.motherQualification,
    required this.fatherDesignation,
    required this.motherDesignation,
    required this.fatherOffice,
    required this.motherOffice,
    required this.registrationDate,
    required this.approveForAdmission,
    required this.quota,
    required this.eligibility,
    required this.medium,
    required this.division,
    required this.schoolPRN,
    required this.admissionCancel,
    required this.admissionCancelDate,
    required this.admissionCancelReason,
    required this.signature,
  });

  factory StudentPersonalDetail.fromJson(Map<String, dynamic> json) {
    return StudentPersonalDetail(
      studentId: int.tryParse((json['StudentId'] ?? '0').toString()) ?? 0,
      studentName: (json['StudentName'] ?? '').toString(),
      email: (json['Email'] ?? '').toString(),
      photo: (json['Photo'] ?? '').toString(),
      studentClass: (json['Class'] ?? '').toString(),
      category: (json['Category'] ?? '').toString(),
      academicYear: (json['AcademicYear'] ?? '').toString(),
      gender: (json['Gender'] ?? '').toString(),
      bloodGroup: (json['BloodGroup'] ?? '').toString(),
      nationality: (json['Nationality'] ?? '').toString(),
      dateOfBirth: (json['DateOfBirth'] ?? '').toString(),
      placeOfBirth: (json['PlaceOfBirth'] ?? '').toString(),
      aadhaarCardNo: (json['AadhaarCardNo'] ?? '').toString(),
      panCardNo: (json['PanCardNo'])?.toString(),
      religion: (json['Religion'] ?? '').toString(),
      contactNo: (json['ContactNo'] ?? '').toString(),
      address: (json['Address'] ?? '').toString(),
      city: (json['City'] ?? '').toString(),
      pincode: (json['Pincode'] ?? '').toString(),
      state: (json['State'] ?? '').toString(),
      gaoOrTown: (json['GaoOrTown'])?.toString(),
      district: (json['District'])?.toString(),
      healthInfo: (json['HealthInfo'])?.toString(),
      physicalHandicap: (json['PhysicalHandicap'] ?? '').toString(),
      physicalHandicapType: (json['PhysicalHandicapType'])?.toString(),
      maharashtraDomicile: (json['MaharashtraDomicile'] ?? false) == true,
      fatherName: (json['FatherName'] ?? '').toString(),
      motherName: (json['MotherName'] ?? '').toString(),
      fatherContact: (json['FatherContact'] ?? '').toString(),
      motherContact: (json['MotherContact'] ?? '').toString(),
      fatherDOB: (json['FatherDOB'])?.toString(),
      motherDOB: (json['MotherDOB'])?.toString(),
      fatherQualification: (json['FatherQualification'])?.toString(),
      motherQualification: (json['MotherQualification'])?.toString(),
      fatherDesignation: (json['FatherDesignation'])?.toString(),
      motherDesignation: (json['MotherDesignation'])?.toString(),
      fatherOffice: (json['FatherOffice'])?.toString(),
      motherOffice: (json['MotherOffice'])?.toString(),
      registrationDate: (json['RegistrationDate'] ?? '').toString(),
      approveForAdmission: (json['ApproveForAdmission'] ?? false) == true,
      quota: (json['Qouta'])?.toString(),
      eligibility: (json['Eligibility'])?.toString(),
      medium: (json['Medium'])?.toString(),
      division: (json['Division'])?.toString(),
      schoolPRN: (json['SchoolPRN'] ?? '').toString(),
      admissionCancel: (json['AdmissionCancel'] ?? '').toString(),
      admissionCancelDate: (json['AdmissionCancelDate'])?.toString(),
      admissionCancelReason: (json['AdmissionCancelReason'])?.toString(),
      signature: (json['Signature'])?.toString(),
    );
  }
}

class GuardianDetail {
  final String name;
  final String address;
  final String mobileNo;
  final String relationWithStudent;

  const GuardianDetail({
    required this.name,
    required this.address,
    required this.mobileNo,
    required this.relationWithStudent,
  });

  factory GuardianDetail.fromJson(Map<String, dynamic> json) {
    return GuardianDetail(
      name: (json['Name'] ?? '').toString(),
      address: (json['Address'] ?? '').toString(),
      mobileNo: (json['MobileNo'] ?? '').toString(),
      relationWithStudent: (json['RelationWithStudent'] ?? '').toString(),
    );
  }
}

class PreviousSchoolItem {
  final String name;
  final String location;
  final String studentClass;
  final String years;
  final String language;
  final String curriculum;

  const PreviousSchoolItem({
    required this.name,
    required this.location,
    required this.studentClass,
    required this.years,
    required this.language,
    required this.curriculum,
  });

  factory PreviousSchoolItem.fromJson(Map<String, dynamic> json) {
    return PreviousSchoolItem(
      name: (json['Name'] ?? '').toString(),
      location: (json['Location'] ?? '').toString(),
      studentClass: (json['Class'] ?? '').toString(),
      years: (json['Years'] ?? '').toString(),
      language: (json['Language'] ?? '').toString(),
      curriculum: (json['Curriculum'] ?? '').toString(),
    );
  }
}

class BankDetail {
  final String accountType;
  final String bankName;
  final String bankAccountNo;
  final String branch;
  final String branchCode;
  final String micrCode;
  final String ifscCode;
  final String holderName;
  final String bankDetails;
  final String adharLinked;
  final String mobileLinked;

  const BankDetail({
    required this.accountType,
    required this.bankName,
    required this.bankAccountNo,
    required this.branch,
    required this.branchCode,
    required this.micrCode,
    required this.ifscCode,
    required this.holderName,
    required this.bankDetails,
    required this.adharLinked,
    required this.mobileLinked,
  });

  factory BankDetail.fromJson(Map<String, dynamic> json) {
    return BankDetail(
      accountType: (json['AccountType'] ?? '').toString(),
      bankName: (json['BankName'] ?? '').toString(),
      bankAccountNo: (json['BackAccountNo'] ?? '').toString(),
      branch: (json['Branch'] ?? '').toString(),
      branchCode: (json['BrachCode'] ?? '').toString(),
      micrCode: (json['MICRCode'] ?? '').toString(),
      ifscCode: (json['IFSCCode'] ?? '').toString(),
      holderName: (json['HolderName'] ?? '').toString(),
      bankDetails: (json['BankDetails'] ?? '').toString(),
      adharLinked: (json['Adharlinked'] ?? '').toString(),
      mobileLinked: (json['MobileLinked'] ?? '').toString(),
    );
  }
}

class IncomeDetail {
  final String haveCertificate;
  final double amount;
  final String certNo;
  final String issueDate;
  final String validUpTo;
  final String panNo;
  final String adharNo;

  const IncomeDetail({
    required this.haveCertificate,
    required this.amount,
    required this.certNo,
    required this.issueDate,
    required this.validUpTo,
    required this.panNo,
    required this.adharNo,
  });

  factory IncomeDetail.fromJson(Map<String, dynamic> json) {
    return IncomeDetail(
      haveCertificate: (json['HaveCertificate'] ?? '').toString(),
      amount: ((json['Amount'] ?? 0).toString()) == 'null' ? 0.0 : double.tryParse((json['Amount']).toString()) ?? 0.0,
      certNo: (json['CertNo'] ?? '').toString(),
      issueDate: (json['IssudeDate'] ?? '').toString(),
      validUpTo: (json['VlidUpTo'] ?? '').toString(),
      panNo: (json['PanNo'] ?? '').toString(),
      adharNo: (json['AdharNo'] ?? '').toString(),
    );
  }
}

class CasteReligionDetail {
  final String religion;
  final String category;
  final String? caste;
  final String? subCaste;
  final String castCertificate;
  final String certificateNo;
  final String issuedDate;
  final String barCode;
  final String issuedAuthority;
  final String castValidity;
  final String castValNo;
  final String castValDate;
  final String castValCode;
  final String casteValObtnAuthority;
  final String nonCreamyLayer;
  final String noclNo;
  final String nonCLDate;
  final String nclBarcode;
  final String nclIssuedAuthority;

  const CasteReligionDetail({
    required this.religion,
    required this.category,
    required this.caste,
    required this.subCaste,
    required this.castCertificate,
    required this.certificateNo,
    required this.issuedDate,
    required this.barCode,
    required this.issuedAuthority,
    required this.castValidity,
    required this.castValNo,
    required this.castValDate,
    required this.castValCode,
    required this.casteValObtnAuthority,
    required this.nonCreamyLayer,
    required this.noclNo,
    required this.nonCLDate,
    required this.nclBarcode,
    required this.nclIssuedAuthority,
  });

  factory CasteReligionDetail.fromJson(Map<String, dynamic> json) {
    return CasteReligionDetail(
      religion: (json['Religion'] ?? '').toString(),
      category: (json['Category'] ?? '').toString(),
      caste: json['Caste']?.toString(),
      subCaste: json['SubCaste']?.toString(),
      castCertificate: (json['CastCertificate'] ?? '').toString(),
      certificateNo: (json['CertificateNo'] ?? '').toString(),
      issuedDate: (json['IssuedDate'] ?? '').toString(),
      barCode: (json['BarCode'] ?? '').toString(),
      issuedAuthority: (json['IssuedAuthority'] ?? '').toString(),
      castValidity: (json['CastValidity'] ?? '').toString(),
      castValNo: (json['CastValNo'] ?? '').toString(),
      castValDate: (json['CastValDate'] ?? '').toString(),
      castValCode: (json['CastValCode'] ?? '').toString(),
      casteValObtnAuthority: (json['CasteValObtnAuthority'] ?? '').toString(),
      nonCreamyLayer: (json['NonCreamyLayer'] ?? '').toString(),
      noclNo: (json['NOCLNo'] ?? '').toString(),
      nonCLDate: (json['NonCLDate'] ?? '').toString(),
      nclBarcode: (json['NCLBarcode'] ?? '').toString(),
      nclIssuedAuthority: (json['NCLIssuedAuthority'] ?? '').toString(),
    );
  }
}

class DocumentCategory {
  final int id;
  final String category;
  final List<StudentDocument> documents;

  const DocumentCategory({required this.id, required this.category, required this.documents});

  factory DocumentCategory.fromJson(Map<String, dynamic> json) {
    final List<StudentDocument> docs = (json['Documents'] as List<dynamic>? ?? [])
        .map((e) => StudentDocument.fromJson(e as Map<String, dynamic>))
        .toList();
    return DocumentCategory(
      id: int.tryParse((json['Id'] ?? '0').toString()) ?? 0,
      category: (json['Category'] ?? '').toString(),
      documents: docs,
    );
  }
}

class StudentDocument {
  final int id;
  final int docTypeId;
  final int documentId;
  final String docType;
  final String? documentPath;
  final int sequence;
  final int studentId;
  final int typeId;

  const StudentDocument({
    required this.id,
    required this.docTypeId,
    required this.documentId,
    required this.docType,
    required this.documentPath,
    required this.sequence,
    required this.studentId,
    required this.typeId,
  });

  factory StudentDocument.fromJson(Map<String, dynamic> json) {
    return StudentDocument(
      id: int.tryParse((json['Id'] ?? '0').toString()) ?? 0,
      docTypeId: int.tryParse((json['DocTypeId'] ?? '0').toString()) ?? 0,
      documentId: int.tryParse((json['DocumentId'] ?? '0').toString()) ?? 0,
      docType: (json['DocType'] ?? '').toString(),
      documentPath: json['DocumentPath']?.toString(),
      sequence: int.tryParse((json['Sequence'] ?? '0').toString()) ?? 0,
      studentId: int.tryParse((json['StudentId'] ?? '0').toString()) ?? 0,
      typeId: int.tryParse((json['TypeId'] ?? '0').toString()) ?? 0,
    );
  }

  String? get documentUrl => (documentPath == null || documentPath!.isEmpty) ? null : '${ApiConstants.baseUrl}/Documents/$documentPath';
}


