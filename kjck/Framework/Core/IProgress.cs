public interface IProgress
{
    float process { get; }
    bool isDone { get; }
    bool isTimeOut { get; }
    string processMessage { get; }
}
