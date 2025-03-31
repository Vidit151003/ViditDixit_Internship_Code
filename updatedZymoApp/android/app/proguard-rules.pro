-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

-keepattributes JavascriptInterface
-keepattributes *Annotation*

-dontwarn com.razorpay.**
-keep class com.razorpay.** {*;}
-keep class androidx.lifecycle.DefaultLifecycleObserver
-optimizations !method/inlining/*

-keepclasseswithmembers class * {
public void onPayment*(...);
}
