import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:AES/constants/api_constants.dart';

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

  static Future<AdminFeesDetails?> fetchStudentFeesDetails({required int studentId}) async {
    try {
      // Try GET first as per API hint (expects Id in query)
      final getUrl = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.studentFeesDetails}?Id=$studentId');
      final getRes = await http.get(getUrl, headers: {'Accept': 'application/json'});
      if (getRes.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(getRes.body);
        if (jsonData['success'] == true && jsonData['data'] is Map<String, dynamic>) {
          return AdminFeesDetails.fromJson(jsonData['data'] as Map<String, dynamic>);
        }
      }

      // Fallback to POST (multipart) with UId like other endpoints
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      final postUrl = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.studentFeesDetails}');
      final request = http.MultipartRequest('POST', postUrl);
      request.fields['Id'] = studentId.toString();
      request.fields['UId'] = uid;
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] is Map<String, dynamic>) {
          return AdminFeesDetails.fromJson(jsonData['data'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (_) {
      return null;
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

class AdminFeesDetails {
  final List<ClassPaymentDetails> classWiseDetails;
  final List<StudentPaymentItem> studentPayments;
  final String studentName;
  final String acadYear;
  final int? classId;
  final int studentId;
  final String className;
  final String? photo;
  final String? category;
  final String? caste;
  final int? admissionYear;
  final String? admissionCategory;
  final double? refundAmount;
  final dynamic tempFees;

  const AdminFeesDetails({
    required this.classWiseDetails,
    required this.studentPayments,
    required this.studentName,
    required this.acadYear,
    required this.classId,
    required this.studentId,
    required this.className,
    required this.photo,
    required this.category,
    required this.caste,
    required this.admissionYear,
    required this.admissionCategory,
    required this.refundAmount,
    required this.tempFees,
  });

  factory AdminFeesDetails.fromJson(Map<String, dynamic> json) {
    final List<dynamic> cw = json['ClassWiseStdPaymentDetailsVM'] as List<dynamic>? ?? [];
    final List<dynamic> sp = json['StudentPaymentDetails'] as List<dynamic>? ?? [];
    return AdminFeesDetails(
      classWiseDetails: cw.map((e) => ClassPaymentDetails.fromJson(e as Map<String, dynamic>)).toList(),
      studentPayments: sp.map((e) => StudentPaymentItem.fromJson(e as Map<String, dynamic>)).toList(),
      studentName: (json['StudentName'] ?? '').toString(),
      acadYear: (json['AcadYear'] ?? '').toString(),
      classId: (json['ClassId']) == null ? null : int.tryParse(json['ClassId'].toString()),
      studentId: int.tryParse((json['StudentId'] ?? '0').toString()) ?? 0,
      className: (json['ClassName'] ?? '').toString(),
      photo: json['Photo']?.toString(),
      category: json['Category']?.toString(),
      caste: json['Caste']?.toString(),
      admissionYear: json['AdmissionYear'] == null ? null : int.tryParse(json['AdmissionYear'].toString()),
      admissionCategory: json['AdmissionCategory']?.toString(),
      refundAmount: json['RefundAmount'] == null ? null : (json['RefundAmount'] is num ? (json['RefundAmount'] as num).toDouble() : double.tryParse(json['RefundAmount'].toString())),
      tempFees: json['TempFees'],
    );
  }
}

class ClassPaymentDetails {
  final int classId;
  final int studentId;
  final String className;
  final List<PayDetail> payDetails;

  const ClassPaymentDetails({required this.classId, required this.studentId, required this.className, required this.payDetails});

  factory ClassPaymentDetails.fromJson(Map<String, dynamic> json) {
    final List<dynamic> p = json['PayDetails'] as List<dynamic>? ?? [];
    return ClassPaymentDetails(
      classId: int.tryParse((json['ClassId'] ?? '0').toString()) ?? 0,
      studentId: int.tryParse((json['StudentId'] ?? '0').toString()) ?? 0,
      className: (json['ClassName'] ?? '').toString(),
      payDetails: p.map((e) => PayDetail.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class PayDetail {
  final int feeId;
  final int classId;
  final int studentId;
  final double amount;
  final String payMode;
  final double fixedFee;
  final double balanceFee;
  final String particular;
  final String feeType;
  final int feesTypeId;
  final bool isLateFee;
  final double lateFeeAmount;
  final String? lastDate;
  final bool isPerDay;
  final bool isLate;
  final double? lateAmount;
  final int feeHead;
  final String? paymentMode;
  final String? details;
  final String? bankName;
  final String? chequeNo;
  final String className;

  const PayDetail({
    required this.feeId,
    required this.classId,
    required this.studentId,
    required this.amount,
    required this.payMode,
    required this.fixedFee,
    required this.balanceFee,
    required this.particular,
    required this.feeType,
    required this.feesTypeId,
    required this.isLateFee,
    required this.lateFeeAmount,
    required this.lastDate,
    required this.isPerDay,
    required this.isLate,
    required this.lateAmount,
    required this.feeHead,
    required this.paymentMode,
    required this.details,
    required this.bankName,
    required this.chequeNo,
    required this.className,
  });

  factory PayDetail.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return PayDetail(
      feeId: int.tryParse((json['FeeId'] ?? '0').toString()) ?? 0,
      classId: int.tryParse((json['ClassId'] ?? '0').toString()) ?? 0,
      studentId: int.tryParse((json['StudentId'] ?? '0').toString()) ?? 0,
      amount: parseDouble(json['Amount']),
      payMode: (json['PayMode'] ?? '').toString(),
      fixedFee: parseDouble(json['FixedFee']),
      balanceFee: parseDouble(json['BalanceFee']),
      particular: (json['Particular'] ?? '').toString(),
      feeType: (json['FeeType'] ?? '').toString(),
      feesTypeId: int.tryParse((json['FeesTypeId'] ?? '0').toString()) ?? 0,
      isLateFee: json['IsLateFee'] == true,
      lateFeeAmount: parseDouble(json['LateFeeAmount']),
      lastDate: json['LastDate']?.toString(),
      isPerDay: json['IsPerDay'] == true,
      isLate: json['IsLate'] == true,
      lateAmount: json['LateAmount'] == null ? null : parseDouble(json['LateAmount']),
      feeHead: int.tryParse((json['FeeHead'] ?? '0').toString()) ?? 0,
      paymentMode: json['PaymentMode']?.toString(),
      details: json['Details']?.toString(),
      bankName: json['BankName']?.toString(),
      chequeNo: json['ChequeNo']?.toString(),
      className: (json['ClassName'] ?? '').toString(),
    );
  }
}

class StudentPaymentItem {
  final String className;
  final String receiptNo;
  final String? customerRefNo;
  final String particular;
  final String paymentMode;
  final String? chequeNo;
  final String? details;
  final String createdDate;
  final double? lateFeeAmount;
  final double amount;

  const StudentPaymentItem({
    required this.className,
    required this.receiptNo,
    required this.customerRefNo,
    required this.particular,
    required this.paymentMode,
    required this.chequeNo,
    required this.details,
    required this.createdDate,
    required this.lateFeeAmount,
    required this.amount,
  });

  factory StudentPaymentItem.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return StudentPaymentItem(
      className: (json['ClassName'] ?? '').toString(),
      receiptNo: (json['RecpNo'] ?? '').toString(),
      customerRefNo: json['CustomerRefNo']?.toString(),
      particular: (json['Particular'] ?? '').toString(),
      paymentMode: (json['PaymentMode'] ?? '').toString(),
      chequeNo: json['ChequeNo']?.toString(),
      details: json['Details']?.toString(),
      createdDate: (json['CreatedDate'] ?? '').toString(),
      lateFeeAmount: json['LateFeeAmount'] == null ? null : parseDouble(json['LateFeeAmount']),
      amount: parseDouble(json['Amount']),
    );
  }
}


