using UnityEngine;

public interface IWin
{
    void Bind(Scene scene, string winnName);
    void Enter();
    void Enter(object obj);
    void Exit();
    void Refresh();
    void Return();
    void Help();
    void Focus();

    bool active { get; set; }
    bool isFixed { get; set; }
    bool isBackLayer { get; set; }
    bool autoHide { get; set; }
    int sort { get; set; }
    int mutex { get; set; }
    int depth { get; set; }
    string winName { get; }
    Win.SizeStyle sizeStyle { get; set; }
    Win.Status status { get; }
    Scene scene { get; }
    Bounds bounds { get; set; }
}