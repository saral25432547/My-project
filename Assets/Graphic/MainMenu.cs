using UnityEngine;
using UnityEngine.SceneManagement;

public class MainMenu : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        Time.timeScale = 1f;
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void Button_Start()
    {
        SceneManager.LoadScene("ScenesSample"); // เปลี่ยนเป็นชื่อ Scene จริงถ้าใช้ชื่ออื่น
    }

    public void Button_Quit()
    {
        #if UNITY_EDITOR
        UnityEditor.EditorApplication.isPlaying = false; // หยุด Play mode ใน Editor
        #else
        Application.Quit(); // ออกจากเกมจริงเมื่อ Build
        #endif
    }
}
