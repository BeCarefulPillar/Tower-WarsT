using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class CoreModule : MonoBehaviour
{
    protected static void Instance<T>(ref T instance) where T : CoreModule
    {
        if (Game.instance == null)
        {
            Debug.LogError("Init [" + typeof(T).Name + "] need Game instance!");
            return;
        }

        if (instance == null)
        {
            instance = FindObjectOfType<T>();

            if (instance == null)
            {
                GameObject go = AssetManager.LoadPrefab(typeof(T).Name);
                if (go)
                {
                    go = Instantiate(go) as GameObject;

                    instance = go.GetComponent<T>();

                    if (instance == null)
                    {
                        Destroy(go);
                        Debug.Log("Prefab for [" + typeof(T).Name + "] dose not contains the component");
                    }
                    else
                    {
                        go.name = typeof(T).Name;
                    }
                }
                else
                {
                    Debug.Log("Can't find prefab for [" + typeof(T).Name +"]");
                }

                if (instance == null)
                {
                    instance = new GameObject(typeof(T).Name).AddComponent<T>();
                }
            }
        }

        MoveToGame(instance.gameObject);
    }

    protected static void MoveToGame(GameObject go)
    {
        if (go && Game.instance)
        {
            go.SetActive(true);

            GameObject game = Game.instance.gameObject;

            if (go == game) return;

            if (go.layer != game.layer) NGUITools.SetLayer(go, game.layer);
            Transform trans = go.transform;
            trans.SetParent(game.transform);
            trans.localPosition = Vector3.zero;
            trans.localRotation = Quaternion.identity;
            trans.localScale = Vector3.one;
        }
    }
}
