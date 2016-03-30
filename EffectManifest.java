import java.lang.annotation.*;

@Retention(RetentionPolicy.RUNTIME)
public @interface EffectManifest {
    String name();
    String author();
    String description();
}
