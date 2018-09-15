using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.Internal;

public interface IMonoBehaviour
{
    #region Object
    string name { get; set; }
    int GetInstanceID();
    #endregion

    #region Component
    string tag { get; set; }
    GameObject gameObject { get; }
    Transform transform { get; }

    bool CompareTag(string tag);

    void BroadcastMessage(string methodName);
    void BroadcastMessage(string methodName, object parameter);
    void BroadcastMessage(string methodName, SendMessageOptions options);
    void BroadcastMessage(string methodName, [DefaultValue("null")] object parameter, [DefaultValue("SendMessageOptions.RequireReceiver")] SendMessageOptions options);

    void SendMessage(string methodName);
    void SendMessage(string methodName, object value);
    void SendMessage(string methodName, SendMessageOptions options);
    void SendMessage(string methodName, [DefaultValue("null")] object value, [DefaultValue("SendMessageOptions.RequireReceiver")] SendMessageOptions options);

    void SendMessageUpwards(string methodName);
    void SendMessageUpwards(string methodName, SendMessageOptions options);
    void SendMessageUpwards(string methodName, object value);
    void SendMessageUpwards(string methodName, [DefaultValue("null")] object value, [DefaultValue("SendMessageOptions.RequireReceiver")] SendMessageOptions options);

    Component GetComponent(Type type);
    Component GetComponent(string type);
    T GetComponent<T>();

    Component GetComponentInChildren(Type t);
    Component GetComponentInChildren(Type t, bool includeInactive);
    T GetComponentInChildren<T>();
    T GetComponentInChildren<T>([DefaultValue("false")] bool includeInactive);

    Component GetComponentInParent(Type t);
    T GetComponentInParent<T>();

    Component[] GetComponents(Type type);
    void GetComponents(Type type, List<Component> results);
    T[] GetComponents<T>();
    void GetComponents<T>(List<T> results);

    Component[] GetComponentsInChildren(Type t);
    Component[] GetComponentsInChildren(Type t, [DefaultValue("false")] bool includeInactive);
    T[] GetComponentsInChildren<T>();
    T[] GetComponentsInChildren<T>(bool includeInactive);
    void GetComponentsInChildren<T>(List<T> results);
    void GetComponentsInChildren<T>(bool includeInactive, List<T> result);

    Component[] GetComponentsInParent(Type t);
    Component[] GetComponentsInParent(Type t, [DefaultValue("false")] bool includeInactive);

    T[] GetComponentsInParent<T>();
    T[] GetComponentsInParent<T>(bool includeInactive);
    void GetComponentsInParent<T>(bool includeInactive, List<T> results);
    #endregion

    #region Behaviour
    bool enabled { get; set; }
    bool isActiveAndEnabled { get; }
    #endregion

    #region MonoBehaviour
    bool useGUILayout { get; set; }
    void CancelInvoke();
    void CancelInvoke(string methodName);
    void Invoke(string methodName, float time);
    void InvokeRepeating(string methodName, float time, float repeatRate);
    bool IsInvoking();
    bool IsInvoking(string methodName);
    Coroutine StartCoroutine(IEnumerator routine);
    Coroutine StartCoroutine(string methodName);
    Coroutine StartCoroutine(string methodName, [DefaultValue("null")] object value);
    void StopAllCoroutines();
    void StopCoroutine(string methodName);
    void StopCoroutine(IEnumerator routine);
    void StopCoroutine(Coroutine routine);
    #endregion
}
