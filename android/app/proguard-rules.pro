# Keep line numbers for stack traces
-keepattributes SourceFile,LineNumberTable

# Do not obfuscate Chiaki classes
-dontobfuscate
-keep class com.metallic.chiaki.** { *; }

##########################################
# Native Methods (CRITICAL for JNI)
##########################################
-keepclasseswithmembernames class * {
    native <methods>;
}

##########################################
# Room Database
##########################################
-keep class * extends androidx.room.RoomDatabase
-keep @androidx.room.Database class *
-keep @androidx.room.Entity class *
-keep @androidx.room.Dao class *
-dontwarn androidx.room.paging.**

##########################################
# RxJava
##########################################
-keep class io.reactivex.** { *; }
-keep interface io.reactivex.** { *; }
-dontwarn io.reactivex.**

##########################################
# Kotlin
##########################################
-keep class kotlin.Metadata { *; }
-keepnames @kotlin.Metadata class com.metallic.chiaki.**

##########################################
# Parcelable
##########################################
-keep class * implements android.os.Parcelable {
    public static final ** CREATOR;
}

##########################################
# Keep annotations
##########################################
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions

##########################################
# Moshi
##########################################

# JSR 305 annotations are for embedding nullability information.
-dontwarn javax.annotation.**

-keepclasseswithmembers class * {
    @com.squareup.moshi.* <methods>;
}

-keep @com.squareup.moshi.JsonQualifier interface *

# Enum field names are used by the integrated EnumJsonAdapter.
-keepclassmembers @com.squareup.moshi.JsonClass class * extends java.lang.Enum {
    <fields>;
    **[] values();
}

# The name of @JsonClass types is used to look up the generated adapter.
-keepnames @com.squareup.moshi.JsonClass class *

# Retain generated target class's synthetic defaults constructor
-keepnames class kotlin.jvm.internal.DefaultConstructorMarker
-keepclassmembers @com.squareup.moshi.JsonClass @kotlin.Metadata class * {
    synthetic <init>(...);
}

# Retain generated JsonAdapters if annotated type is retained
-if @com.squareup.moshi.JsonClass class *
-keep class <1>JsonAdapter { *; }
-if @com.squareup.moshi.JsonClass class **$*
-keep class <1>_<2>JsonAdapter { *; }
-if @com.squareup.moshi.JsonClass class **$*$*
-keep class <1>_<2>_<3>JsonAdapter { *; }
-if @com.squareup.moshi.JsonClass class **$*$*$*
-keep class <1>_<2>_<3>_<4>JsonAdapter { *; }
-if @com.squareup.moshi.JsonClass class **$*$*$*$*
-keep class <1>_<2>_<3>_<4>_<5>JsonAdapter { *; }
-if @com.squareup.moshi.JsonClass class **$*$*$*$*$*
-keep class <1>_<2>_<3>_<4>_<5>_<6>JsonAdapter { *; }

# Wildcard keep for all Moshi-generated adapters
-keep class **JsonAdapter { *; }
