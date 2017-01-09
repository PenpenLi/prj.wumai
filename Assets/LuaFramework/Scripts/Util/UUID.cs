using UnityEngine;

/// <summary>
/// 工具封装
/// Ancher : Canyon
/// Create : 2016-03-21 15:16
/// </summary>
namespace Tkits
{
    using System.Collections;
    using System.Net.NetworkInformation;

    public static class UUID
    {
        // 唯一标识
        static string cacheUUID = "";
        static string cacheUUIDMD5 = "";
        static string cacheUID = "";
        static string cacheUIDMD5 = "";

        static public string getMacAddress()
        {
            string macAdress = "";
            NetworkInterface[] nics = NetworkInterface.GetAllNetworkInterfaces();

            foreach (NetworkInterface adapter in nics)
            {
                PhysicalAddress address = adapter.GetPhysicalAddress();
                macAdress = address.ToString();
                if (!string.IsNullOrEmpty(macAdress))
                {
                    return macAdress;
                }
            }
            return "00";
        }

        static public string uuid {
            get
            {
                if (string.IsNullOrEmpty(cacheUUID))
                {
                    if (Application.platform == RuntimePlatform.Android ||
                        Application.platform == RuntimePlatform.IPhonePlayer)
                    {
                        cacheUUID = SystemInfo.deviceUniqueIdentifier;
                    }
                    else
                    {
                        cacheUUID = getMacAddress();
                    }
                }
                return cacheUUID;
            }
        }

        static public string uuidMd5
        {
            get
            {
                if (string.IsNullOrEmpty(cacheUUIDMD5))
                {
                    cacheUUIDMD5 = MD5Encrypt.encrypt(uuid);
                }
                return cacheUUIDMD5;
            }
        }

        static public string uid
        {
            get
            {
                if (string.IsNullOrEmpty(cacheUID))
                {
                    cacheUID = Application.platform + "_" + uuid;
                }
                return cacheUID;
            }
        }

        static public string uidMd5
        {
            get
            {
                if (string.IsNullOrEmpty(cacheUIDMD5))
                {
                    cacheUIDMD5 = MD5Encrypt.encrypt(uid); 
                }
                return cacheUIDMD5;
            }
        }
    }

    public static class MD5Encrypt
    {
        static private System.Security.Cryptography.MD5 _MD5;

        static public System.Security.Cryptography.MD5 MD5
        {
            get
            {
                if (_MD5 == null)
                {
                    return _MD5 = new System.Security.Cryptography.MD5CryptoServiceProvider();
                }
                return _MD5;
            }
        }

        static public string encrypt(byte[] val)
        {
            byte[] encrypts = MD5.ComputeHash(val);

            System.Text.StringBuilder sbuild = new System.Text.StringBuilder();
            for (int i = 0; i < encrypts.Length - 1; i++)
            {
                sbuild.Append(encrypts[i].ToString("x").PadLeft(2, '0'));
            }
            string str = sbuild.ToString();
            sbuild.Length = 0;
            return str;
        }

        static public string encrypt(object val)
        {
            if (val == null)
            {
                return "";
            }
            byte[] data = System.Text.Encoding.Default.GetBytes(val.ToString());
            return encrypt(data);
        }

        static public string encrypt16(object val) {
            string _ev = encrypt(val);
            if (string.IsNullOrEmpty(_ev)) {
                return _ev;
            }
            return _ev.Substring(8, 16);
        }
    }
}