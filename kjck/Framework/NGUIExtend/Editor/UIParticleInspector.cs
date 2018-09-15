//NGUI Extend Copyright © 何权

using UnityEngine;
using UnityEditor;
using System.Collections;

[CustomEditor(typeof(UIParticle), true)]
public class UIParticleInspector : UIWidgetInspector
{
    UIParticle mParticle;
    long lastTicks = 0;
    //float deltaTime = 0f;

    protected override void OnEnable()
    {
        base.OnEnable();
        mParticle = target as UIParticle;
        lastTicks = System.DateTime.Now.Ticks;
        EditorApplication.update += OnUpdate;
    }

    protected override void OnDisable()
    {
        base.OnDisable();
        EditorApplication.update -= OnUpdate;
    }

    private void OnUpdate()
    {
        //deltaTime += (float)((System.DateTime.Now.Ticks - lastTicks) / 10000000d);
        //if (deltaTime >= 1f / 60f)
        //{
        //    mParticle.OnEditorUpdate(1f / 60f);
        //    deltaTime -= 1f / 60f;
        //}
        if (mParticle && mParticle.enabled  && mParticle.cachedGameObject.activeInHierarchy)
        {
            float deltaTime = (float)((System.DateTime.Now.Ticks - lastTicks) / 10000000d);
            mParticle.OnEditorUpdate(deltaTime);
            lastTicks = System.DateTime.Now.Ticks;
        }
    }

    /// <summary>
    /// 图集选择回调.
    /// </summary>
    void OnSelectAtlas(Object obj)
    {
        mParticle.atlas = obj as UIAtlas;
        NGUITools.SetDirty(serializedObject.targetObject);
        NGUISettings.atlas = obj as UIAtlas;
    }

    /// <summary>
    /// 精灵选择回调.
    /// </summary>
    void SelectSprite(string spriteName)
    {
        mParticle.spriteName = spriteName;
        NGUITools.SetDirty(serializedObject.targetObject);
        NGUISettings.selectedSprite = spriteName;
    }

    void DrawFloatValue(UIParticle.P_Float value, string label) { DrawFloatValue(value, label, new Rect(0f, 0f, 1f, 1f)); }
    void DrawFloatValue(UIParticle.P_Float value, string label, Rect curveRect)
    {
        if (value == null) return;
        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField(label, label.Length > 1 ? GUILayout.Width(100f) : GUILayout.Width(20f));

        if (value.style == UIParticle.ValueStyle.Const)
        {
            value.min = EditorGUILayout.FloatField(value.min, GUILayout.MinWidth(80), GUILayout.MaxWidth(240));
        }
        else if (value.style == UIParticle.ValueStyle.RandomTwoConstants)
        {
            value.min = EditorGUILayout.FloatField(value.min, GUILayout.MinWidth(80), GUILayout.MaxWidth(240));
            value.max = EditorGUILayout.FloatField(value.max, GUILayout.MinWidth(80), GUILayout.MaxWidth(240));
        }
        else if (value.style == UIParticle.ValueStyle.Curve)
        {
            value.minCurve =EditorGUILayout.CurveField(value.minCurve,Color.red,curveRect, GUILayout.MinWidth(80), GUILayout.MaxWidth(240));
        }
        else if (value.style == UIParticle.ValueStyle.RandomTwoCurves)
        {
            value.minCurve = EditorGUILayout.CurveField(value.minCurve,Color.red,curveRect, GUILayout.MinWidth(40), GUILayout.MaxWidth(120));
            value.maxCurve = EditorGUILayout.CurveField(value.maxCurve,Color.green,curveRect, GUILayout.MinWidth(40), GUILayout.MaxWidth(120));
        }
        value.style = (UIParticle.ValueStyle)EditorGUILayout.EnumPopup(value.style, GUILayout.MinWidth(40), GUILayout.MaxWidth(120));
        EditorGUILayout.EndHorizontal();
    }

    void DrawParticleValue(string propName, string label)
    {
        SerializedProperty sp = serializedObject.FindProperty(propName);
        if (sp == null || !sp.type.StartsWith("P_")) return;

        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField(label, GUILayout.Width(100f));
        
        UIParticle.ValueStyle style = (UIParticle.ValueStyle)sp.FindPropertyRelative("style").enumValueIndex;
        if (style == UIParticle.ValueStyle.Const)
        {
            EditorGUILayout.PropertyField(sp.FindPropertyRelative("min"), GUIContent.none, GUILayout.MinWidth(80), GUILayout.MaxWidth(240));
        }
        else if (style == UIParticle.ValueStyle.RandomTwoConstants)
        {
            EditorGUILayout.PropertyField(sp.FindPropertyRelative("min"), GUIContent.none, GUILayout.MinWidth(40), GUILayout.MaxWidth(120));
            EditorGUILayout.PropertyField(sp.FindPropertyRelative("max"), GUIContent.none, GUILayout.MinWidth(40), GUILayout.MaxWidth(120));
        }
        else if (style == UIParticle.ValueStyle.Curve)
        {
            EditorGUILayout.PropertyField(sp.FindPropertyRelative("minCurve"), GUIContent.none, GUILayout.MinWidth(80), GUILayout.MaxWidth(240));
        }
        else if (style == UIParticle.ValueStyle.RandomTwoCurves)
        {
            EditorGUILayout.PropertyField(sp.FindPropertyRelative("minCurve"), GUIContent.none, GUILayout.MinWidth(40), GUILayout.MaxWidth(120));
            EditorGUILayout.PropertyField(sp.FindPropertyRelative("maxCurve"), GUIContent.none, GUILayout.MinWidth(40), GUILayout.MaxWidth(120));
        }
        EditorGUILayout.PropertyField(sp.FindPropertyRelative("style"), GUIContent.none, GUILayout.MinWidth(40), GUILayout.MaxWidth(120));
        EditorGUILayout.EndHorizontal();
    }

    protected override bool ShouldDrawProperties()
    {
        if (!mParticle.mainTexture || mParticle.atlas)
        {
            GUILayout.BeginHorizontal();
            if (NGUIEditorTools.DrawPrefixButton("Atlas", GUILayout.Width(64f))) ComponentSelector.Show<UIAtlas>(OnSelectAtlas);
            mParticle.atlas = EditorGUILayout.ObjectField(mParticle.atlas, typeof(UIAtlas), false) as UIAtlas;
            if (GUILayout.Button("Edit", GUILayout.Width(40f)))
            {
                if (mParticle.atlas)
                {
                    NGUISettings.atlas = mParticle.atlas;
                    NGUIEditorTools.Select(mParticle.atlas.gameObject);
                }
            }
            GUILayout.EndHorizontal();
            if (!mParticle.hasFrameAnimation) NGUIEditorTools.DrawAdvancedSpriteField(mParticle.atlas, mParticle.spriteName, SelectSprite, false);
        }
        if ((!mParticle.mainTexture && !mParticle.atlas) || mParticle.material)
        {
            mParticle.material = EditorGUILayout.ObjectField("Material", mParticle.material, typeof(Material), false) as Material;
        }
        if(!mParticle.material && !mParticle.atlas)
        {
            mParticle.mainTexture = EditorGUILayout.ObjectField("Texture", mParticle.mainTexture, typeof(Texture), false) as Texture;
            mParticle.shader = EditorGUILayout.ObjectField("Shader", mParticle.shader, typeof(Shader), false) as Shader;
        }

        mParticle.flip = (UIEffectFlip)EditorGUILayout.EnumPopup("Flip", mParticle.flip);

        mParticle.isActualBounds = EditorGUILayout.Toggle("ActualBound", mParticle.isActualBounds);

        mParticle.isStretched = EditorGUILayout.Toggle("Stretched", mParticle.isStretched);
        if (mParticle.isStretched)
        {
            mParticle.lengthScale = EditorGUILayout.FloatField("Length Scale", mParticle.lengthScale);
            mParticle.speedScale = EditorGUILayout.FloatField("Speed Scale", mParticle.speedScale);
        }

        NGUIEditorTools.DrawSeparator();

        return mParticle.mainTexture;
    }

    protected override void DrawCustomProperties()
    {
        GUILayout.Space(6f);

        EditorGUIUtility.labelWidth = 104;

        mParticle.duration = EditorGUILayout.FloatField("Duration", mParticle.duration);
        mParticle.loop = EditorGUILayout.Toggle("Looping", mParticle.loop);
        mParticle.ignoreTimeScale = EditorGUILayout.Toggle("IgnoreTimeScale", mParticle.ignoreTimeScale);
        if (!mParticle.loop) mParticle.autoDestroy = EditorGUILayout.Toggle("Auto Destroy", mParticle.autoDestroy);
        mParticle.startDelay = EditorGUILayout.FloatField("Start Delay", mParticle.startDelay);

        DrawFloatValue(mParticle.startLifetime, "Start Lifetime", new Rect(0f, 0f, 1f, mParticle.startLifetime.min));
        DrawFloatValue(mParticle.startSpeed, "Start Speed", new Rect(0f, mParticle.startSpeed.min, 1f, mParticle.startSpeed.max - mParticle.startSpeed.min));
        DrawFloatValue(mParticle.startSize, "Start Size", new Rect(0f, mParticle.startSize.min, 1f, mParticle.startSize.max - mParticle.startSize.min));
        DrawFloatValue(mParticle.startRotation, "Start Rotation", new Rect(0f, 0f, 1f, mParticle.startRotation.min));
        DrawParticleValue("mStartColor", "Start Color");
        
        mParticle.gravityModifier = EditorGUILayout.FloatField("Gravity ", mParticle.gravityModifier);
        mParticle.inheritVelocity = EditorGUILayout.FloatField("Inherit Velocity", mParticle.inheritVelocity);
        mParticle.Relative = EditorGUILayout.ObjectField("Relative Space", mParticle.Relative, typeof(Transform), true) as Transform;
        mParticle.playOnAwake = EditorGUILayout.Toggle("Play On Awake", mParticle.playOnAwake);
        mParticle.maxParticles = EditorGUILayout.IntField("Max Particles", mParticle.maxParticles);

        bool ennabled = mParticle.enableEmission;
        if (DrawHeader("Emission", ref ennabled))
        {
            EditorGUI.BeginDisabledGroup(!ennabled);
            EditorGUILayout.BeginHorizontal();
            if (mParticle.isEmitCurveRate)
            {
                mParticle.emissionRate = EditorGUILayout.CurveField("Rate", mParticle.emissionRate, Color.green, new Rect(0, 0, 1f, mParticle.emissionRateConst), GUILayout.MinWidth(180), GUILayout.MaxWidth(340));
            }
            else
            {
                mParticle.emissionRateConst = EditorGUILayout.IntField("Rate", mParticle.emissionRateConst, GUILayout.MinWidth(180), GUILayout.MaxWidth(340));
            }
            int idx = EditorGUILayout.Popup(mParticle.isEmitCurveRate ? 1 : 0, new string[2] { "Const", "Curve" }, GUILayout.MinWidth(40), GUILayout.MaxWidth(120));
            mParticle.isEmitCurveRate = idx == 1;
            EditorGUILayout.EndHorizontal();

            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("Bursts", GUILayout.Width(100));
            EditorGUILayout.LabelField("Time", GUILayout.Width(80));
            EditorGUILayout.LabelField("Particles", GUILayout.Width(80));
            EditorGUILayout.EndHorizontal();

            SerializedProperty sp1 = serializedObject.FindProperty("mBurstsTime");
            SerializedProperty sp2 = serializedObject.FindProperty("mBurstsParticles");
            int size = sp1.arraySize;
            for (int i = 0; i < size; i++)
            {
                EditorGUILayout.BeginHorizontal();
                GUILayout.Space(100f);
                sp1.GetArrayElementAtIndex(i).floatValue = Mathf.Min(EditorGUILayout.FloatField("", sp1.GetArrayElementAtIndex(i).floatValue, GUILayout.Width(80)), mParticle.duration);
                sp2.GetArrayElementAtIndex(i).intValue = Mathf.Max(0, EditorGUILayout.IntField("", sp2.GetArrayElementAtIndex(i).intValue, GUILayout.Width(80)));
                if (i == size - 1 && GUILayout.Button("-", GUILayout.Width(20)))
                {
                    sp1.arraySize--;
                    sp2.arraySize--;
                }
                EditorGUILayout.EndHorizontal();
            }
            if (GUILayout.Button("+", GUILayout.Width(20)))
            {
                sp1.arraySize++;
                sp2.arraySize++;
            }

            EditorGUI.EndDisabledGroup();
        }
        mParticle.enableEmission = ennabled;

        ennabled = mParticle.hasShape;
        if (DrawHeader("Shape", ref ennabled))
        {
            EditorGUI.BeginDisabledGroup(!ennabled);

            mParticle.shape.style = (UIParticle.ShapeStyle)EditorGUILayout.EnumPopup("Shape", mParticle.shape.style);
            mParticle.shape.center = EditorGUILayout.Vector3Field("Center", mParticle.shape.center);
            mParticle.shape.rotation = Quaternion.Euler(EditorGUILayout.Vector3Field("Rotation", mParticle.shape.rotation.eulerAngles));
            if (mParticle.shape.style == UIParticle.ShapeStyle.Sphere || mParticle.shape.style == UIParticle.ShapeStyle.HemiSphere)
            {
                mParticle.shape.radius = EditorGUILayout.FloatField("Radius", mParticle.shape.radius);
                int idx = Mathf.Clamp(mParticle.shape.emitFrom - 2, 0, 2);
                idx = EditorGUILayout.Popup("Emit From", idx, new string[3] { "Center", "Volume", "Shell" });
                mParticle.shape.emitFrom = (byte)(idx + 2);
            }
            else if (mParticle.shape.style == UIParticle.ShapeStyle.Cone)
            {
                mParticle.shape.angle = EditorGUILayout.FloatField("Angle", mParticle.shape.angle);
                mParticle.shape.radius = EditorGUILayout.FloatField("Radius", mParticle.shape.radius);

                EditorGUI.BeginDisabledGroup(mParticle.shape.emitFrom != 3 && mParticle.shape.emitFrom != 4);
                mParticle.shape.length = EditorGUILayout.FloatField("Length", mParticle.shape.length);
                EditorGUI.EndDisabledGroup();

                int idx = Mathf.Clamp(mParticle.shape.emitFrom - 1, 0, 3);
                idx = EditorGUILayout.Popup("Emit From", idx, new string[4] { "Base", "Base Shell", "Volume", "Volume Shell" });
                mParticle.shape.emitFrom = (byte)(idx + 1);
            }
            else if (mParticle.shape.style == UIParticle.ShapeStyle.Box)
            {
                mParticle.shape.box = EditorGUILayout.Vector3Field("Size", mParticle.shape.box);
                bool ef = EditorGUILayout.Toggle("Emit From Shell", mParticle.shape.emitFrom == 2 || mParticle.shape.emitFrom == 4);
                mParticle.shape.emitFrom = (byte)(ef ? 2 : 1);
            }
            else if (mParticle.shape.style == UIParticle.ShapeStyle.Ellipsoid)
            {
                mParticle.shape.box = EditorGUILayout.Vector3Field("Size", mParticle.shape.box);
                int idx = Mathf.Clamp(mParticle.shape.emitFrom - 2, 0, 2);
                idx = EditorGUILayout.Popup("Emit From", idx, new string[3] { "Center", "Volume", "Shell" });
                mParticle.shape.emitFrom = (byte)(idx + 2);
            }
            mParticle.shape.randomDirection = EditorGUILayout.Toggle("Random Direction", mParticle.shape.randomDirection);

            EditorGUI.EndDisabledGroup();
        }
        mParticle.hasShape = ennabled;

        ennabled = mParticle.hasVelocityByLife;
        if (DrawHeader("Velocity Over Lifetime", ref ennabled))
        {
            EditorGUI.BeginDisabledGroup(!ennabled);

            DrawFloatValue(mParticle.velocityByLife[0], "X", new Rect(0f, mParticle.velocityByLife[0].min, 1f, mParticle.velocityByLife[0].max - mParticle.velocityByLife[0].min));
            DrawFloatValue(mParticle.velocityByLife[1], "Y", new Rect(0f, mParticle.velocityByLife[1].min, 1f, mParticle.velocityByLife[1].max - mParticle.velocityByLife[1].min));
            DrawFloatValue(mParticle.velocityByLife[2], "Z", new Rect(0f, mParticle.velocityByLife[2].min, 1f, mParticle.velocityByLife[2].max - mParticle.velocityByLife[2].min));

            EditorGUI.EndDisabledGroup();
        }
        mParticle.hasVelocityByLife = ennabled;

        ennabled = mParticle.hasLimitVelocityByLife;
        if (DrawHeader("Limit Velocity Over Lifetime", ref ennabled))
        {
            EditorGUI.BeginDisabledGroup(!ennabled);

            if (mParticle.limitVelocityByLife != null)
            {
                DrawFloatValue(mParticle.limitVelocityByLife[0], "X", new Rect(0f, mParticle.limitVelocityByLife[0].min, 1f, mParticle.limitVelocityByLife[0].max - mParticle.limitVelocityByLife[0].min));
                DrawFloatValue(mParticle.limitVelocityByLife[1], "Y", new Rect(0f, mParticle.limitVelocityByLife[1].min, 1f, mParticle.limitVelocityByLife[1].max - mParticle.limitVelocityByLife[1].min));
                DrawFloatValue(mParticle.limitVelocityByLife[2], "Z", new Rect(0f, mParticle.limitVelocityByLife[2].min, 1f, mParticle.limitVelocityByLife[2].max - mParticle.limitVelocityByLife[2].min));
            }

            mParticle.limitVelocityDampen = EditorGUILayout.FloatField("Dampen", mParticle.limitVelocityDampen);

            EditorGUI.EndDisabledGroup();
        }
        mParticle.hasLimitVelocityByLife = ennabled;

        ennabled = mParticle.hasForceByLife;
        if (DrawHeader("Force Over Lifetime", ref ennabled))
        {
            EditorGUI.BeginDisabledGroup(!ennabled);

            DrawFloatValue(mParticle.forceByLife[0], "X", new Rect(0f, mParticle.forceByLife[0].min, 1f, mParticle.forceByLife[0].max - mParticle.forceByLife[0].min));
            DrawFloatValue(mParticle.forceByLife[1], "Y", new Rect(0f, mParticle.forceByLife[1].min, 1f, mParticle.forceByLife[1].max - mParticle.forceByLife[1].min));
            DrawFloatValue(mParticle.forceByLife[2], "Z", new Rect(0f, mParticle.forceByLife[2].min, 1f, mParticle.forceByLife[2].max - mParticle.forceByLife[2].min));

            if (mParticle.forceByLife[0].style == UIParticle.ValueStyle.RandomTwoConstants || mParticle.forceByLife[0].style == UIParticle.ValueStyle.RandomTwoCurves ||
                mParticle.forceByLife[1].style == UIParticle.ValueStyle.RandomTwoConstants || mParticle.forceByLife[1].style == UIParticle.ValueStyle.RandomTwoCurves ||
                mParticle.forceByLife[2].style == UIParticle.ValueStyle.RandomTwoConstants || mParticle.forceByLife[2].style == UIParticle.ValueStyle.RandomTwoCurves)
            {
                mParticle.forceRandomize = EditorGUILayout.Toggle("Randomize", mParticle.forceRandomize);
            }
            else
            {
                mParticle.forceRandomize = false;
            }

            EditorGUI.EndDisabledGroup();
        }
        mParticle.hasForceByLife = ennabled;

        ennabled = mParticle.hasColorByLife;
        if (DrawHeader("Color Over Lifetime", ref ennabled))
        {
            EditorGUI.BeginDisabledGroup(!ennabled);

            DrawParticleValue("mColorByLife", "Color");

            EditorGUI.EndDisabledGroup();
        }
        mParticle.hasColorByLife = ennabled;

        ennabled = mParticle.hasSizeByLife;
        if (DrawHeader("Size Over Lifetime", ref ennabled))
        {
            EditorGUI.BeginDisabledGroup(!ennabled);

            DrawFloatValue(mParticle.sizeByLife, "Size", new Rect(0f, mParticle.sizeByLife.min, 1f, mParticle.sizeByLife.max - mParticle.sizeByLife.min));

            EditorGUI.EndDisabledGroup();
        }
        mParticle.hasSizeByLife = ennabled;

        ennabled = mParticle.hasRotationByLife;
        if (DrawHeader("Rotation Over Lifetime", ref ennabled))
        {
            EditorGUI.BeginDisabledGroup(!ennabled);

            DrawFloatValue(mParticle.rotationByLife, "Agular Velocity", new Rect(0f, mParticle.rotationByLife.min, 1f, mParticle.rotationByLife.max - mParticle.rotationByLife.min));

            EditorGUI.EndDisabledGroup();
        }
        mParticle.hasRotationByLife = ennabled;

        ennabled = mParticle.hasFrameAnimation;
        if (mParticle.atlas)
        {
            if (DrawHeader("Sprite Animation Over Lifetime", ref ennabled))
            {
                EditorGUI.BeginDisabledGroup(!ennabled);

                int fc = 0;
                for (int i = 0; i < mParticle.atlas.spriteList.Count; i++)
                {
                    if (string.IsNullOrEmpty(mParticle.spriteName) || mParticle.atlas.spriteList[i].name.StartsWith(mParticle.spriteName)) fc++;
                }
                fc = Mathf.Max(fc - 1, 1);

                mParticle.spriteName = EditorGUILayout.TextField("Sprite Prefix", mParticle.spriteName);
                DrawFloatValue(mParticle.frameOverLifeTime, "Frame Over Lifetime", new Rect(0f, 0, 1f, fc));
                mParticle.cycles = EditorGUILayout.IntField("Cycles", mParticle.cycles);


                mParticle.frameOverLifeTime.min = Mathf.Clamp(mParticle.frameOverLifeTime.min, 0, fc);
                mParticle.frameOverLifeTime.max = Mathf.Clamp(mParticle.frameOverLifeTime.max, 0, fc);
                
                EditorGUI.EndDisabledGroup();
            }
        }
        else
        {
            if (DrawHeader("Texture Animation Over Lifetime", ref ennabled))
            {
                EditorGUI.BeginDisabledGroup(!ennabled);

                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.LabelField("Tiles", GUILayout.Width(100));
                EditorGUIUtility.labelWidth = 12;
                mParticle.tilesX = EditorGUILayout.IntField("X", mParticle.tilesX);
                mParticle.tilesY = EditorGUILayout.IntField("Y", mParticle.tilesY);
                EditorGUIUtility.labelWidth = 104;
                EditorGUILayout.EndHorizontal();

                int fc = Mathf.Max(mParticle.tilesX * mParticle.tilesY - 1, 1);

                DrawFloatValue(mParticle.frameOverLifeTime, "Frame Over Lifetime", new Rect(0f, 0, 1f, fc));
                mParticle.cycles = EditorGUILayout.IntField("Cycles", mParticle.cycles);

                
                mParticle.frameOverLifeTime.min = Mathf.Clamp(mParticle.frameOverLifeTime.min, 0, fc);
                mParticle.frameOverLifeTime.max = Mathf.Clamp(mParticle.frameOverLifeTime.max, 0, fc);

                EditorGUI.EndDisabledGroup();
            }
        }
        if (mParticle.hasFrameAnimation != ennabled)
        {
            mParticle.hasFrameAnimation = ennabled;
            mParticle.GenUV();
        }

        ennabled = mParticle.hasSwirl;
        if (DrawHeader("Particle Swirl", ref ennabled))
        {
            EditorGUI.BeginDisabledGroup(!ennabled);

            mParticle.swirlCenter = EditorGUILayout.Vector3Field("Center", mParticle.swirlCenter);
            mParticle.swirlAxis = EditorGUILayout.Vector3Field("Rotation Axis", mParticle.swirlAxis);
            mParticle.swirlRadius = EditorGUILayout.FloatField("Radius", mParticle.swirlRadius);
            mParticle.swirlAngularSpeed = EditorGUILayout.FloatField("Angular Speed", mParticle.swirlAngularSpeed);
            mParticle.swirlSuckSpeed = EditorGUILayout.FloatField("Suck Speed", mParticle.swirlSuckSpeed);
            mParticle.swirlDampen = EditorGUILayout.FloatField("Dampen", mParticle.swirlDampen);

            EditorGUI.EndDisabledGroup();
        }
        mParticle.hasSwirl = ennabled;

        //模拟
        NGUIEditorTools.DrawSeparator();

        EditorGUILayout.BeginHorizontal();
        if (mParticle.isPlaying)
        {
            if (GUILayout.Button("Pause")) mParticle.Pause();
        }
        else
        {
            if (GUILayout.Button("Simulate")) mParticle.Play();
        }
        if (GUILayout.Button("Stop")) mParticle.Stop();
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField("Play Time " + mParticle.time);
        EditorGUILayout.LabelField("particle Count " + mParticle.particleCount);
        EditorGUILayout.EndHorizontal();

        //UIWidget
        NGUIEditorTools.DrawSeparator();

        base.DrawCustomProperties();

        if (mParticle.isPlaying || GUI.changed) mParticle.MarkAsChanged();
    }

    public static bool DrawHeader(string title, ref bool enabled)
    {
        bool state = EditorPrefs.GetBool(title, true);

        if (!state) GUI.backgroundColor = new Color(0.8f, 0.8f, 0.8f);
        GUILayout.BeginHorizontal();
        GUI.changed = false;

        GUILayout.BeginHorizontal();
        enabled = GUILayout.Toggle(enabled, GUIContent.none, GUILayout.Width(12));
        GUI.contentColor = EditorGUIUtility.isProSkin ? new Color(1f, 1f, 1f, 0.7f) : new Color(0f, 0f, 0f, 0.7f);

        string label = state ? "\u25BC" + (char)0x200a + title : "\u25BA" + (char)0x200a + title;
        if (!GUILayout.Toggle(true, label, "dragtab", GUILayout.MinWidth(20f)))
        {
            state = !state;
        }

        GUI.contentColor = Color.white;
        GUILayout.EndHorizontal();

        if (GUI.changed) EditorPrefs.SetBool(title, state);
        GUILayout.EndHorizontal();
        GUI.backgroundColor = Color.white;
        if (!state) GUILayout.Space(3f);
        return state;
    }
}