## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**

## Preserve exceptions
-keep class * extends java.lang.Exception

## Google Play Services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

## Gson (JSON serialization)
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.** { *; }

## Keep all model classes and their fields for JSON serialization
-keep class * implements java.io.Serializable { *; }
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

## Preserve all native method names and the names of their classes
-keepclasseswithmembernames class * {
    native <methods>;
}

## Keep setters in Views so that animations can still work
-keepclassmembers public class * extends android.view.View {
   void set*(***);
   *** get*();
}

## Preserve enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

## Keep Parcelables
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

## SharedPreferences - Keep all classes that use SharedPreferences
-keep class android.content.SharedPreferences { *; }
-keep class android.content.SharedPreferences$Editor { *; }
-keepclassmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet);
}

## Dio HTTP client
-keep class io.flutter.plugins.** { *; }
-keep class com.example.alpha_track.** { *; }

## Keep all Dart-related classes (critical for Flutter)
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.common.** { *; }

## R8 full mode compatibility
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

## Prevent obfuscation of classes with native methods
-keepclasseswithmembers class * {
    native <methods>;
}

## Keep custom exceptions
-keep public class * extends java.lang.Exception

## Additional rules for reflection-based libraries
-keepattributes RuntimeVisibleAnnotations
-keepattributes RuntimeInvisibleAnnotations
-keepattributes RuntimeVisibleParameterAnnotations
-keepattributes RuntimeInvisibleParameterAnnotations

## Keep generic signatures for reflection
-keepattributes Signature
-keepattributes InnerClasses

## Optimization settings
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5
-allowaccessmodification
-dontpreverify

## Keep line numbers for debugging stack traces
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

## CRITICAL: Keep all Flutter plugin classes
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

## CRITICAL: Keep SharedPreferences implementation
-keep class androidx.preference.** { *; }
-keep class android.content.SharedPreferences** { *; }

## CRITICAL: Prevent obfuscation of method channels
-keep class * extends io.flutter.plugin.common.MethodChannel { *; }
-keep class * extends io.flutter.plugin.common.EventChannel { *; }

## CRITICAL: Keep all classes that might be accessed via reflection
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

## CRITICAL: Dio and network classes
-keepattributes *Annotation*
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

## CRITICAL: Keep all data model classes (adjust package name as needed)
-keep class * {
    <fields>;
    <methods>;
}

## CRITICAL: Prevent stripping of native methods
-keepclasseswithmembers class * {
    native <methods>;
}

## CRITICAL: Keep all serializable classes
-keepnames class * implements java.io.Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}