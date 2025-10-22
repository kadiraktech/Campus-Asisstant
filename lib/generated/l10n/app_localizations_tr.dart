// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get dashboardTitle => 'Kontrol Paneli';

  @override
  String get upcomingCoursesTitle => 'Yaklaşan Dersler';

  @override
  String get pendingTasksTitle => 'Bekleyen Görevler';

  @override
  String get todaysWeatherTitle => 'Bugünün Hava Durumu';

  @override
  String get goodMorning => 'Günaydın';

  @override
  String get goodAfternoon => 'Tünaydın';

  @override
  String get goodEvening => 'İyi Akşamlar';

  @override
  String get myCoursesTitle => 'Derslerim';

  @override
  String get calendarTitle => 'Takvim';

  @override
  String get myTasksTitle => 'Görevlerim';

  @override
  String get weeklyScheduleTitle => 'Haftalık Program';

  @override
  String get weatherSetCityPrompt => 'Hava durumunu görmek için ayarlardan varsayılan şehrinizi ayarlayın.';

  @override
  String weatherLoadError(String cityName, String error) {
    return '$cityName için hava durumu yüklenemedi: $error';
  }

  @override
  String get weatherDataNotAvailable => 'Hava durumu verisi mevcut değil.';

  @override
  String get noUpcomingCourses => 'Önümüzdeki 2 gün içinde yaklaşan ders yok.';

  @override
  String get noPendingTasks => 'Bugün veya sonrası için bekleyen görev yok.';

  @override
  String get showLess => 'Daha Az Göster';

  @override
  String get showMore => 'Daha Fazla Göster';

  @override
  String get profileMenuProfile => 'Profilim';

  @override
  String get profileMenuSettings => 'Ayarlar';

  @override
  String get profileMenuLogout => 'Çıkış Yap';

  @override
  String get logoutConfirmTitle => 'Çıkışı Onayla';

  @override
  String get logoutConfirmContent => 'Çıkış yapmak istediğinizden emin misiniz?';

  @override
  String get cancelAction => 'İptal';

  @override
  String get logoutAction => 'Çıkış Yap';

  @override
  String get languageSettingTitle => 'Dil';

  @override
  String get themeSettingTitle => 'Tema';

  @override
  String get activeTasksTab => 'Aktif';

  @override
  String get completedTasksTab => 'Tamamlandı';

  @override
  String get editTaskTitle => 'Görevi Düzenle';

  @override
  String get addTaskTitle => 'Yeni Görev Ekle';

  @override
  String get taskNameLabel => 'Görev Adı';

  @override
  String get taskNameHint => 'Görevinizin adını girin';

  @override
  String get taskNameValidationEmpty => 'Lütfen görev adını girin.';

  @override
  String get taskNameValidationLength => 'Görev adı 100 karakteri geçemez.';

  @override
  String get taskDescriptionLabel => 'Açıklama (İsteğe Bağlı)';

  @override
  String get taskDescriptionHint => 'Görev hakkında daha fazla detay ekleyin';

  @override
  String get taskCategoryLabel => 'Kategori *';

  @override
  String get taskCategoryValidationEmpty => 'Lütfen bir kategori seçin.';

  @override
  String get selectDueDateLabel => 'Bitiş Tarihi Seç *';

  @override
  String get dueDatePrefix => 'Bitiş: ';

  @override
  String get reminderTimePrefix => 'Hatırlatma Zamanı: ';

  @override
  String get reminderTimeNotSet => 'Ayarlanmadı';

  @override
  String get clearReminderTooltip => 'Hatırlatıcıyı Temizle';

  @override
  String get updateTaskButton => 'Görevi Güncelle';

  @override
  String get addTaskButton => 'Görev Ekle';

  @override
  String get selectDueDateError => 'Lütfen bir bitiş tarihi seçin.';

  @override
  String get reminderBeforeDueError => 'Hatırlatma zamanı bitiş tarihinden önce olmalıdır.';

  @override
  String get mustBeLoggedInError => 'Görevleri kaydetmek için giriş yapmış olmalısınız.';

  @override
  String get profileNotLoadedError => 'Kullanıcı profili yüklenemedi. Görev hatırlatıcıları kaydedilemiyor.';

  @override
  String get taskAddedSuccess => 'Görev başarıyla eklendi!';

  @override
  String get taskUpdatedSuccess => 'Görev başarıyla güncellendi!';

  @override
  String taskSaveFailed(String error) {
    return 'Görev kaydedilemedi: $error';
  }

  @override
  String get confirmDeleteTitle => 'Silmeyi Onayla';

  @override
  String get confirmDeleteContent => 'Bu görevi silmek istediğinizden emin misiniz?';

  @override
  String get deleteAction => 'Sil';

  @override
  String get taskDeletedSuccess => 'Görev başarıyla silindi!';

  @override
  String taskDeleteFailed(String error) {
    return 'Görev silinemedi: $error';
  }

  @override
  String get timePickerOkText => 'Tamam';

  @override
  String get timePickerCancelText => 'İptal';

  @override
  String get taskCategoryAssignment => 'Ödev';

  @override
  String get taskCategoryExam => 'Sınav';

  @override
  String get taskCategoryReminder => 'Hatırlatma';

  @override
  String get taskCategoryOther => 'Diğer';

  @override
  String get taskDeleteConfirmContent => 'Bu görevi silmek istediğinizden emin misiniz?';

  @override
  String get loginTitle => 'Giriş Yap';

  @override
  String get emailLabel => 'E-posta';

  @override
  String get emailHint => 'E-postanızı girin';

  @override
  String get emailValidationEmpty => 'Lütfen e-postanızı girin';

  @override
  String get emailValidationInvalid => 'Lütfen geçerli bir e-posta girin';

  @override
  String get passwordLabel => 'Şifre';

  @override
  String get passwordHint => 'Şifrenizi girin';

  @override
  String get passwordValidationEmpty => 'Lütfen şifrenizi girin';

  @override
  String get passwordValidationLength => 'Şifre en az 6 karakter olmalıdır';

  @override
  String get loginButton => 'Giriş Yap';

  @override
  String get loginWithGoogleButton => 'Google ile Giriş Yap';

  @override
  String get noAccountPrompt => 'Hesabınız yok mu? ';

  @override
  String get registerButton => 'Kayıt Ol';

  @override
  String loginFailed(String error) {
    return 'Giriş başarısız: $error';
  }

  @override
  String get loginCancelled => 'Giriş kullanıcı tarafından iptal edildi.';

  @override
  String get googleSignInError => 'Google ile giriş sırasında bilinmeyen bir hata oluştu.';

  @override
  String get registerTitle => 'Kayıt Ol';

  @override
  String get registrationSuccessful => 'Kayıt Başarılı! Lütfen giriş yapın.';

  @override
  String get registrationErrorDefault => 'Kayıt sırasında bir hata oluştu.';

  @override
  String get registrationErrorWeakPassword => 'Sağlanan şifre çok zayıf.';

  @override
  String get registrationErrorEmailInUse => 'Bu e-posta için zaten bir hesap mevcut.';

  @override
  String registrationErrorFirebase(String error) {
    return 'Kayıt başarısız: $error';
  }

  @override
  String get registrationErrorUnexpected => 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.';

  @override
  String get createAccountPrompt => 'Kampüs hayatınızı organize etmeye başlamak için yeni bir hesap oluşturun!';

  @override
  String get registerEmailValidationEmpty => 'Lütfen e-postanızı girin';

  @override
  String get registerEmailValidationInvalid => 'Lütfen geçerli bir e-posta adresi girin';

  @override
  String get registerPasswordValidationEmpty => 'Lütfen şifrenizi girin';

  @override
  String get registerPasswordValidationLength => 'Şifre en az 6 karakter uzunluğunda olmalıdır';

  @override
  String get registerButtonRegister => 'Kayıt Ol';

  @override
  String get alreadyHaveAccountPrompt => 'Zaten bir hesabınız var mı? ';

  @override
  String get loginButtonFromRegister => 'Giriş Yap';

  @override
  String get loginWelcomeBack => 'Tekrar Hoş Geldiniz!';

  @override
  String get loginManageSchedule => 'Kampüs programınızı yönetmek için giriş yapın.';

  @override
  String get loginRememberMe => 'Beni Hatırla';

  @override
  String get loginForgotPassword => 'Şifremi Unuttum?';

  @override
  String get loginOrSeparator => 'VEYA';

  @override
  String get loginLoggingIn => 'Giriş Yapılıyor...';

  @override
  String get loginSigningInGoogle => 'Giriş Yapılıyor...';

  @override
  String get loginErrorUserNotFound => 'Bu e-posta için kullanıcı bulunamadı.';

  @override
  String get loginErrorWrongPassword => 'Bu kullanıcı için yanlış şifre.';

  @override
  String get loginErrorInvalidCredentials => 'Geçersiz kimlik bilgileri. Lütfen e-posta ve şifrenizi kontrol edin.';

  @override
  String get loginErrorGeneric => 'Giriş sırasında bir hata oluştu.';

  @override
  String get loginErrorUnexpected => 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.';

  @override
  String get googleSignInErrorGeneric => 'Google ile Giriş sırasında bir hata oluştu.';

  @override
  String get googleSignInErrorUnexpected => 'Beklenmeyen bir Google ile Giriş hatası oluştu.';

  @override
  String get googleSignInProfileError => 'Profil detayları kaydedilemedi, ancak giriş başarılı.';

  @override
  String get forgotPasswordTitle => 'Şifreyi Sıfırla';

  @override
  String get forgotPasswordSuccessMessage => 'Şifre sıfırlama e-postası gönderildi. Lütfen gelen kutunuzu kontrol edin.';

  @override
  String get forgotPasswordErrorFailedToSend => 'Şifre sıfırlama e-postası gönderilemedi.';

  @override
  String get forgotPasswordErrorUserNotFound => 'Bu e-posta için kullanıcı bulunamadı.';

  @override
  String forgotPasswordErrorFirebase(String error) {
    return 'Şifre sıfırlama e-postası gönderilemedi: $error';
  }

  @override
  String get forgotPasswordErrorUnexpected => 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.';

  @override
  String get forgotPasswordInstruction => 'E-posta adresinizi girin, şifrenizi sıfırlamanız için size bir bağlantı göndereceğiz.';

  @override
  String get forgotPasswordSendLinkButton => 'Sıfırlama Bağlantısı Gönder';

  @override
  String scheduleDialogTitleFormat(String dayName, String date) {
    return '$dayName, $date';
  }

  @override
  String get scheduleNoCourses => 'Bugün için planlanmış ders yok.';

  @override
  String get scheduleCloseButton => 'Kapat';

  @override
  String scheduleMoreCoursesIndicator(int count) {
    return '+$count tane daha';
  }

  @override
  String get scheduleLoadingErrorTitle => 'Program Yüklenirken Hata Oluştu';

  @override
  String get scheduleLoadingErrorRetryButton => 'Tekrar Dene';

  @override
  String get addCourseTitle => 'Ders Ekle';

  @override
  String get editCourseTitle => 'Dersi Düzenle';

  @override
  String get deleteCourseTooltip => 'Dersi Sil';

  @override
  String get saveCourseTooltip => 'Dersi Kaydet';

  @override
  String get courseNameLabel => 'Ders Adı';

  @override
  String get courseNameValidationEmpty => 'Lütfen ders adını girin';

  @override
  String get courseTimeLabel => 'Saat';

  @override
  String get courseTimeHint => 'SS:dd (örn: 14:30)';

  @override
  String get courseLocationLabel => 'Konum (İsteğe Bağlı)';

  @override
  String get courseLocationHint => 'Konumu ayarlamak için dokunun';

  @override
  String get courseClassroomLabel => 'Sınıf (İsteğe Bağlı)';

  @override
  String get courseInstructorLabel => 'Öğretim Görevlisi (İsteğe Bağlı)';

  @override
  String get courseDayOfWeekLabel => 'Haftanın Günü';

  @override
  String get courseDayOfWeekHint => 'Gün Seçin';

  @override
  String get courseDayOfWeekValidationEmpty => 'Lütfen bir gün seçin';

  @override
  String get courseStartTimeLabel => 'Başlangıç Saati';

  @override
  String get courseEndTimeLabel => 'Bitiş Saati';

  @override
  String get courseSelectTimeHint => 'Saat Seçin';

  @override
  String get courseErrorTimesMissing => 'Lütfen gün, başlangıç ve bitiş saatlerini seçin.';

  @override
  String get courseErrorEndTimeBeforeStart => 'Bitiş saati başlangıç saatinden sonra olmalıdır.';

  @override
  String get courseErrorProfileLoad => 'Kullanıcı profili yüklenemedi. Ders hatırlatıcıları kaydedilemiyor.';

  @override
  String get courseSaveSuccess => 'Ders başarıyla kaydedildi.';

  @override
  String courseSaveFailed(String error) {
    return 'Ders kaydedilemedi: $error';
  }

  @override
  String get courseDeleteConfirmTitle => 'Silmeyi Onayla';

  @override
  String get courseDeleteConfirmContent => 'Bu dersi silmek istediğinizden emin misiniz? Bu işlem aynı zamanda planlanmış hatırlatıcıları da iptal edecektir.';

  @override
  String get courseDeleteConfirmButton => 'Sil';

  @override
  String get courseDeleteSuccess => 'Ders başarıyla silindi.';

  @override
  String courseDeleteFailed(String error) {
    return 'Ders silinemedi: $error';
  }

  @override
  String get courseLocationDialogTitle => 'Konum Ayarla';

  @override
  String get courseLocationDialogHint => 'Bir şehir veya konum arayın...';

  @override
  String get courseLocationDialogSaveButton => 'Kaydet';

  @override
  String get dayMonday => 'Pazartesi';

  @override
  String get dayTuesday => 'Salı';

  @override
  String get dayWednesday => 'Çarşamba';

  @override
  String get dayThursday => 'Perşembe';

  @override
  String get dayFriday => 'Cuma';

  @override
  String get daySaturday => 'Cumartesi';

  @override
  String get daySunday => 'Pazar';

  @override
  String get profileTitle => 'Profilim';

  @override
  String profileLoadError(String error) {
    return 'Profil yüklenemedi: $error';
  }

  @override
  String get profileNotLoggedIn => 'Kullanıcı giriş yapmadı.';

  @override
  String profileDepartmentLabel(String department) {
    return 'Bölüm: $department';
  }

  @override
  String profileStudentIdLabel(String studentId) {
    return 'Öğrenci No: $studentId';
  }

  @override
  String get profileEditButton => 'Profili Düzenle';

  @override
  String get editProfileTitle => 'Profili Düzenle';

  @override
  String get editProfileSaveTooltip => 'Profili Kaydet';

  @override
  String get editProfileLoadErrorTitle => 'Profil yüklenemedi';

  @override
  String get editProfileSuccessTitle => 'Başarılı';

  @override
  String get editProfileEmailUpdateRequiresRelogin => 'E-postanızı değiştirmeden önce lütfen çıkış yapıp tekrar giriş yapın.';

  @override
  String get editProfileEmailUpdateFailed => 'E-posta güncellenemedi';

  @override
  String get editProfileUpdateSuccess => 'Profil başarıyla güncellendi!';

  @override
  String get editProfileUpdateFailedTitle => 'Güncelleme Başarısız';

  @override
  String get editProfileSectionProfileInfo => 'Profil Bilgileri';

  @override
  String get editProfileSectionContactInfo => 'İletişim Bilgileri';

  @override
  String get editProfileSectionPersonalInfo => 'Kişisel Detaylar';

  @override
  String get editProfileImageSourceDialogTitle => 'Resim Kaynağı Seç';

  @override
  String get editProfileImageSourceCamera => 'Kamera';

  @override
  String get editProfileImageSourceGallery => 'Galeri';

  @override
  String get editProfileImageSelectedSuccess => 'Profil resmi seçildi. Değişiklikleri korumak için profili kaydedin.';

  @override
  String get editProfileImagePathSaveErrorTitle => 'Yol Kaydedilirken Hata';

  @override
  String editProfileImagePathSaveErrorContent(String error) {
    return 'Resim yolu yerel olarak kaydedilemedi: $error';
  }

  @override
  String get editProfileUnsavedChangesTitle => 'Kaydedilmemiş Değişiklikler';

  @override
  String get editProfileUnsavedChangesContent => 'Ayrılmadan önce değişikliklerinizi kaydetmek istiyor musunuz?';

  @override
  String get editProfileDiscardButton => 'Vazgeç';

  @override
  String get editProfileSaveButton => 'Kaydet';

  @override
  String get editProfileDisplayNameLabel => 'Görünen Ad';

  @override
  String get editProfileDisplayNameValidation => 'Lütfen adınızı girin';

  @override
  String get editProfileDepartmentLabel => 'Bölüm';

  @override
  String get editProfileStudentIdLabel => 'Öğrenci No';

  @override
  String get editProfilePhoneNumberLabel => 'Telefon Numarası';

  @override
  String get editProfilePhoneNumberValidation => 'Geçersiz telefon numarası (örn. +905xxxxxxxxx)';

  @override
  String get editProfileBioLabel => 'Biyografi';

  @override
  String get editProfileBioHint => 'Kısa bir biyografi girin...';

  @override
  String get editProfileBirthDateLabel => 'Doğum Tarihi';

  @override
  String get editProfileBirthDateHint => 'Tarih Seçin';

  @override
  String get editProfileCompletionTitle => 'Profil Tamamlama';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsProfileNotAvailable => 'Kullanıcı profili kaydedilemiyor.';

  @override
  String get settingsSaveSuccess => 'Ayarlar başarıyla kaydedildi!';

  @override
  String settingsSaveError(String error) {
    return 'Ayarlar kaydedilirken hata oluştu: $error';
  }

  @override
  String settingsCitySuggestionError(String statusCode) {
    return 'Şehir önerileri alınırken hata oluştu: $statusCode';
  }

  @override
  String settingsCitySuggestionNetworkError(String error) {
    return 'Şehir önerileri alınırken ağ hatası: $error';
  }

  @override
  String get settingsSectionProfile => 'Profil Ayarları';

  @override
  String get settingsSectionNotifications => 'Bildirim Ayarları';

  @override
  String get settingsSectionDevice => 'Cihaz Ayarları';

  @override
  String get settingsSectionDeleteAccount => 'Hesabı Sil';

  @override
  String get settingsChangePasswordTile => 'Şifre Değiştir';

  @override
  String get settingsSetCityDialogTitle => 'Varsayılan Şehri Ayarla';

  @override
  String get settingsSetCityDialogHint => 'Bir şehir arayın...';

  @override
  String get settingsDefaultCityTile => 'Hava Durumu için Varsayılan Şehir';

  @override
  String get settingsDefaultCityHint => 'Şehir ayarlamak için dokunun';

  @override
  String get settingsCourseRemindersSwitch => 'Ders Hatırlatıcıları';

  @override
  String get settingsTaskRemindersSwitch => 'Görev Hatırlatıcıları';

  @override
  String get settingsLeadTimeLabel => 'Ders Hatırlatma Süresi (dakika)';

  @override
  String get settingsLeadTimeValidationEmpty => 'Lütfen bir hatırlatma süresi girin';

  @override
  String get settingsLeadTimeValidationNumber => 'Lütfen geçerli bir sayı girin';

  @override
  String get settingsLeadTimeValidationNegative => 'Hatırlatma süresi negatif olamaz';

  @override
  String get settingsDeviceNotificationsTile => 'Bildirim Ayarları';

  @override
  String get settingsDeleteAccountConfirmTitle => 'Hesap Silmeyi Onayla';

  @override
  String get settingsDeleteAccountConfirmContent => 'Hesabınızı kalıcı olarak silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';

  @override
  String get settingsDeleteAccountButton => 'Hesabı Sil';

  @override
  String get settingsDeletingAccountSnackbar => 'Hesap Siliniyor...';

  @override
  String get settingsDeleteAccountSuccessSnackbar => 'Hesap başarıyla silindi.';

  @override
  String settingsDeleteAccountErrorSnackbar(String error) {
    return 'Hesap silinemedi: $error';
  }

  @override
  String get settingsDeleteAccountErrorDialogTitle => 'Hesap Silme Hatası';

  @override
  String get settingsReauthRequiredDialogTitle => 'Yeniden Kimlik Doğrulama Gerekli';

  @override
  String get settingsReauthPasswordPrompt => 'Hesabınızı silmek için lütfen mevcut şifrenizi girin.';

  @override
  String get settingsReauthCurrentPasswordLabel => 'Mevcut Şifre';

  @override
  String get settingsReauthPasswordValidationEmpty => 'Lütfen mevcut şifrenizi girin';

  @override
  String get settingsReauthIncorrectPassword => 'Yanlış şifre.';

  @override
  String get settingsReauthVerifyButton => 'Doğrula';

  @override
  String get settingsChangePasswordDialogTitle => 'Şifre Değiştir';

  @override
  String get settingsChangePasswordNewLabel => 'Yeni Şifre';

  @override
  String get settingsChangePasswordNewValidationEmpty => 'Lütfen yeni bir şifre girin';

  @override
  String get settingsChangePasswordConfirmLabel => 'Yeni Şifreyi Onayla';

  @override
  String get settingsChangePasswordConfirmValidationEmpty => 'Lütfen şifrenizi onaylayın';

  @override
  String get settingsChangePasswordConfirmValidationMismatch => 'Şifreler eşleşmiyor';

  @override
  String get settingsChangePasswordUpdateButton => 'Şifreyi Güncelle';

  @override
  String get settingsChangePasswordSuccessSnackbar => 'Şifre başarıyla güncellendi!';

  @override
  String get settingsChangePasswordFailedDialogTitle => 'Şifre Değiştirme Başarısız';

  @override
  String get settingsErrorDialogTitle => 'Hata';

  @override
  String get settingsSessionExpiredError => 'Kullanıcı oturumu sona erdi. Lütfen tekrar giriş yapın.';

  @override
  String fiveDayForecastTitle(String city) {
    return '$city için 5 Günlük Hava Tahmini';
  }

  @override
  String fiveDayForecastLoadError(String error) {
    return '5 günlük hava tahmini yüklenemedi: $error';
  }

  @override
  String fiveDayForecastNoData(String times) {
    return 'Seçilen saatler ($times) için hava tahmini verisi bulunamadı.';
  }

  @override
  String get fiveDayForecastDayDividerFormat => 'EEEE, d MMM';

  @override
  String get editProfileEmailManagedByGoogle => 'E-posta Google tarafından yönetiliyor';

  @override
  String editProfileCompletionIndicatorLabel(String percentage) {
    return 'Profil Tamamlama: %$percentage';
  }

  @override
  String get calendarUserNotLoggedIn => 'Kullanıcı giriş yapmamış.';

  @override
  String calendarDataLoadError(String sourceType, String error) {
    return '$sourceType verileri yüklenemedi: $error';
  }

  @override
  String get taskStatusCompleted => 'Tamamlandı';

  @override
  String get taskStatusPending => 'Beklemede';

  @override
  String get weatherConditionClear => 'Açık';

  @override
  String get weatherConditionClouds => 'Bulutlu';

  @override
  String get weatherConditionRain => 'Yağmurlu';

  @override
  String get weatherConditionDrizzle => 'Çisenti';

  @override
  String get weatherConditionThunderstorm => 'Gök Gürültülü Fırtına';

  @override
  String get weatherConditionSnow => 'Karlı';

  @override
  String get weatherConditionMist => 'Sisli';

  @override
  String get weatherConditionFog => 'Yoğun Sis';

  @override
  String get weatherConditionUnknown => 'Bilinmiyor';

  @override
  String get displayNameLabel => 'Ad Soyad';

  @override
  String get displayNameValidationEmpty => 'Lütfen adınızı ve soyadınızı girin';

  @override
  String get deleteCourseDialogTitle => 'Dersi Sil';

  @override
  String get deleteCourseDialogContent => 'Bu dersi silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';

  @override
  String courseNotificationUpcomingTitle(String courseName) {
    return 'Yaklaşan Ders: $courseName';
  }

  @override
  String courseNotificationUpcomingBody(String courseName, String courseTime, String courseLocation) {
    return '$courseName dersi $courseTime saatinde $courseLocation konumunda';
  }
}
