using UnityEngine;
using System.Collections;

public class GemSpawner : MonoBehaviour {

    public GameObject[] prefabs;

    // Use this for initialization
    void Start () {

        // infinite coin spawning function, asynchronous
        StartCoroutine(SpawnGems());
    }

    // Update is called once per frame
    void Update () {

    }

    IEnumerator SpawnGems() {
        while (true) {

            // number of coins we could spawn vertically
            //coins spawned 1-4 this time we're only doing 1-2 gems.
            int gemsThisRow = Random.Range(1,2);

            // instantiate all coins in this row separated by some random amount of space
            for (int i = 0; i < gemsThisRow; i++) {
                Instantiate(prefabs[Random.Range(0, prefabs.Length)], new Vector3(26, Random.Range(-10, 10), 10), Quaternion.identity);
            }

            // The coins originally spanwed in a range of 1-5 seconds.
            yield return new WaitForSeconds(Random.Range(10, 20));
        }
    }
}