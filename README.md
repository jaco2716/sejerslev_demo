# Sejerslev Demo
Sejerslev Demo
## Commands
### Build JsonSerializable model classes:
* flutter pub run build_runner build
* flutter pub run build_runner watch

### Build iOS/Android Archive: 
Remember to change version!
* flutter build ipa
* flutter build appbundle

### Google Cloud Platform
Restore backup
* gcloud firestore import gs://ab_one_firestore_backup/[EXPORT FOLDER NAME]
