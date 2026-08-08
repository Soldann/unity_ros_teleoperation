using UnityEngine;
using Unity.XR.CoreUtils;
using Meta.XR.MRUtilityKit;

public class QRFollower : MonoBehaviour
{
    public MRUKTrackable trackable;
    public XROrigin xrOrigin;

    void Update()
    {
        if (trackable == null || xrOrigin == null)
            return;

        // MRUK world pose
        Vector3 mrukPos = trackable.transform.position;
        Quaternion mrukRot = trackable.transform.rotation;

        // Convert MRUK world → XR Origin world
        Vector3 correctedPos = xrOrigin.transform.TransformPoint(mrukPos);
        Quaternion correctedRot = xrOrigin.transform.rotation * mrukRot;

        transform.SetPositionAndRotation(correctedPos, correctedRot);
    }
}
