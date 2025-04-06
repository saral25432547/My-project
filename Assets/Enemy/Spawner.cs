using UnityEngine;
using UnityEngine.Pool;
using TMPro; // เพิ่มการใช้งาน TextMeshPro

public class Spawner : MonoBehaviour
{
    [SerializeField] private Transform[] spawnPoints;
    [SerializeField] private float initialTimeBetweenSpawns = 5f; // เวลาระหว่างการ spawn เริ่มต้นที่ 5 วินาที
    private float timeSinceLastSpawn;
    private float currentTimeBetweenSpawns;

    [SerializeField] private Enemy enemyPrefab;
    private IObjectPool<Enemy> enemyPool;

    [SerializeField] private int maxEnemies = 20;  // กำหนดจำนวนสูงสุดของศัตรูที่สามารถ spawn ได้
    private int currentEnemyCount = 0; // เก็บจำนวนศัตรูที่มีในฉาก
    public int totalEnemiesKilled = 0; // เก็บจำนวนศัตรูที่ฆ่าแล้ว

    [SerializeField] private TextMeshProUGUI killCountText; // เปลี่ยนจาก Text เป็น TextMeshProUGUI
    [SerializeField] private TextMeshProUGUI currentEnemyCountText; // เปลี่ยนจาก Text เป็น TextMeshProUGUI

    private void Awake()
    {
        enemyPool = new ObjectPool<Enemy>(CreateEnemy);
        timeSinceLastSpawn = 0f; // เริ่มต้นเวลาให้เป็น 0
        currentTimeBetweenSpawns = initialTimeBetweenSpawns; // ตั้งค่าระยะเวลาเริ่มต้น
    }

    private Enemy CreateEnemy()
    {
        Enemy enemy = Instantiate(enemyPrefab);
        enemy.SetPool(enemyPool);
        return enemy;
    }

    private void Update()
    {
        // ตรวจสอบว่าถึงเวลาที่จะ spawn ศัตรูแล้วหรือยัง
        if (Time.time >= timeSinceLastSpawn + currentTimeBetweenSpawns && currentEnemyCount < maxEnemies)
        {
            SpawnEnemy(); // เรียก SpawnEnemy เพื่อ spawn ศัตรู
            timeSinceLastSpawn = Time.time; // อัพเดทเวลา
        }

        // ค่อยๆ ลดเวลาระหว่างการ spawn ให้เร็วขึ้น
        if (currentTimeBetweenSpawns > 1f)  // จะไม่ให้ต่ำกว่า 1 วินาที
        {
            currentTimeBetweenSpawns -= Time.deltaTime * 0.001f; // ลดเวลา spawn 0.05 วินาทีต่อวินาที (ช้ากว่าการลด 0.1)
        }

        // อัพเดท UI
        UpdateKillCountUI();
        UpdateEnemyCountUI();
    }

    private void SpawnEnemy()
    {
        // สร้างศัตรูจาก pool และวางตำแหน่งตาม spawnPoints
        Enemy enemy = enemyPool.Get();
        Transform spawnPoint = spawnPoints[Random.Range(0, spawnPoints.Length)];
        enemy.transform.position = spawnPoint.position;
        enemy.gameObject.SetActive(true); // ให้ศัตรูสามารถปรากฏ

        // เพิ่มจำนวนศัตรูในฉาก
        currentEnemyCount++;
        
        // เมื่อศัตรูตายให้ลดจำนวนศัตรูในฉากและเพิ่มคะแนนการฆ่า
        enemy.OnDeath += () => 
        {
            currentEnemyCount--; // ลดจำนวนศัตรูในฉาก
            totalEnemiesKilled++; // เพิ่มคะแนนการฆ่า
        };
    }

    private void UpdateKillCountUI()
    {
        if (killCountText != null)
        {
            killCountText.text = "Enemies Killed: " + totalEnemiesKilled;
        }
    }

    private void UpdateEnemyCountUI()
    {
        if (currentEnemyCountText != null)
        {
            currentEnemyCountText.text = "Enemies in Scene: " + currentEnemyCount;
        }
    }
}
