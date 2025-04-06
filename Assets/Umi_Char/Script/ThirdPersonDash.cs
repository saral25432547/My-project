using UnityEngine;
using System.Collections;

public class ThirdPersonDash : MonoBehaviour
{
    PlayerController playerScript;
    public EnergyBar energyBar;  
    public ParticleSystem dashEffect;
    public GameObject dashHitboxPrefab;  
    public AudioSource dashSound;  // ✅ เพิ่มตัวแปรสำหรับเสียง Dash

    public float dashSpeed = 10f;
    public float dashTime = 0.2f;

    public float maxDashCooldown = 3f; 
    private float currentDashCooldown = 0f;
    private bool canDash = true;

    private GameObject dashHitboxInstance;  

    void Start()
    {
        playerScript = GetComponent<PlayerController>();

        if (dashEffect != null)
            dashEffect.gameObject.SetActive(false); 

        if (energyBar != null)
            energyBar.SetMaxEnergy(maxDashCooldown);  
        else
            Debug.LogError("EnergyBar ยังไม่ได้เชื่อมต่อ! กรุณาเซ็ตใน Inspector");

        if (dashSound == null)
            dashSound = GetComponent<AudioSource>();  // ✅ ดึง AudioSource จากตัวเอง
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.E) && canDash && playerScript.RulerBlade && !playerScript.isGreatSwordMode)
        {
            StartCoroutine(Dash());
        }

        if (!canDash)
        {
            currentDashCooldown += Time.deltaTime;
            energyBar.SetEnergy(currentDashCooldown);

            if (currentDashCooldown >= maxDashCooldown)
            {
                canDash = true;
                currentDashCooldown = maxDashCooldown; 
            }
        }
    }

    IEnumerator Dash()
    {
        canDash = false;
        currentDashCooldown = 0f;
        energyBar.SetEnergy(0);

        if (dashEffect != null)
        {
            dashEffect.gameObject.SetActive(true);
            dashEffect.Play();
        }

        if (dashSound != null)
            dashSound.Play();  // ✅ เล่นเสียง Dash ทันทีที่เริ่ม

        if (dashHitboxInstance == null)
        {
            dashHitboxInstance = Instantiate(dashHitboxPrefab, transform.position, transform.rotation);
            dashHitboxInstance.transform.SetParent(transform); 
        }
        dashHitboxInstance.SetActive(true); 

        float startTime = Time.time;
        Vector3 dashDirection = playerScript.transform.forward;

        if (Input.GetKey(KeyCode.W))
            dashDirection = playerScript.transform.forward;
        else if (Input.GetKey(KeyCode.S))
            dashDirection = -playerScript.transform.forward;
        else if (Input.GetKey(KeyCode.A))
            dashDirection = -playerScript.transform.right;
        else if (Input.GetKey(KeyCode.D))
            dashDirection = playerScript.transform.right;

        while (Time.time < startTime + dashTime)
        {
            playerScript.controller.Move(dashDirection * dashSpeed * Time.deltaTime);
            yield return null;
        }

        if (dashHitboxInstance != null)
        {
            yield return new WaitForSeconds(0.5f); 
            dashHitboxInstance.SetActive(false);
        }

        if (dashEffect != null)
        {
            dashEffect.Stop();
            yield return new WaitForSeconds(0.5f);
            dashEffect.gameObject.SetActive(false);
        }
    }

    public void ResetDashCooldown()
    {
        canDash = true;  
        currentDashCooldown = maxDashCooldown;  
        energyBar.SetEnergy(maxDashCooldown);  
        Debug.Log("คูลดาวน์ Dash ถูกรีเซ็ต!");
    }
}
