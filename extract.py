#!/usr/bin/env python
import os
import UnityPy
import fire
from pathlib import Path
import json
import io


def unpack(source_folder="arknights", destination_folder="arknights_extract"):
    for root, dirs, files in os.walk(source_folder):
        for file_name in files:
            file_path = os.path.join(root, file_name)
            env = UnityPy.load(file_path)
            for path, obj in env.container.items():
                dest = os.path.join(destination_folder, *path.split("/"))
                os.makedirs(os.path.dirname(dest), exist_ok=True)
                dest, ext = os.path.splitext(dest)

                if obj.type.name in ["Texture2D", "Sprite"]:
                    data = obj.read()
                    dest = dest + ".png"
                    data.image.save(dest)
                elif obj.type.name == "TextAsset":
                    data = obj.read()
                    dest = dest + ".txt"
                    with open(dest, "wb") as f:
                        f.write(bytes(data.script))
                elif obj.type.name == "MonoBehaviour":
                    if obj.serialized_type.nodes:
                        tree = obj.read_typetree()
                        dest = dest + ".json"
                        with open(dest, "wt", encoding="utf8") as f:
                            json.dump(tree, f, ensure_ascii=False, indent=4)
                    else:
                        data = obj.read()
                        dest = dest + ".bin"
                        with open(dest, "wb") as f:
                            f.write(data.raw_data)


def decrypt(src):
    from Crypto.Cipher import AES
    from Crypto.Util.Padding import pad, unpad

    # pip install pycryptodome
    # base on https://github.com/InfiniteTsukuyomi/PyAutoGame
    # base on https://github.com/Rhine-Department-0xf/Rhine-DFramwork/blob/main/client/encryption.py
    # follow https://blog.hoshi.tech/archives/70/
    # TODO
    CHAT_MASK = ""
    key = bytearray(CHAT_MASK[:16].encode())
    mask = bytearray(CHAT_MASK[16:].encode())
    iv = bytearray(16)

    def decrypt_text_asset(data):
        for i in range(16):
            iv[i] = data[i] ^ mask[i]
        aes = AES.new(key, AES.MODE_CBC, iv)
        data = aes.decrypt(data[16:])
        data = unpad(data, AES.block_size)
        return data

    for x in Path(src).glob("*.txt"):
        x = open(x, "wb")
        x.write(decrypt_text_asset(x.read()))


def test():
    x = "ArknightsGameData/zh_CN/gamedata/levels/activities/act16side/level_act16side_08.json"
    x = json.loads(open(x).read())
    x0 = x
    x = x0["mapData"]
    m = len(x["map"])
    n = len(x["map"][0])
    print("m,n", m, n)

    ans = [[""] * n for i in range(m)]
    for i, t in enumerate(x["tiles"]):
        y = i % n
        x = i // n
        # print("x,y", x, y)
        if x == 0:
            ans[x][y] = "\n"
        type = t["tileKey"]
        if type == "tile_forbidden":
            ans[x][y] = "x"
        elif type == "tile_start":
            ans[x][y] = "s"
        elif type == "tile_end":
            ans[x][y] = "e"
        elif type == "tile_floor":
            ans[x][y] = "f"
        elif type == "tile_telin":
            ans[x][y] = "i"
        elif type == "tile_telout":
            ans[x][y] = "o"
        elif type == "tile_wall":
            ans[x][y] = "w"
        elif type == "tile_wall":
            ans[x][y] = "w"
        elif type == "tile_road":
            ans[x][y] = " "
        else:
            ans[x][y] = type

    x = x0["predefines"]["tokenInsts"]
    for t in x:
        x, y = t["position"]["row"], t["position"]["col"]
        print("x,y", x, y)

        ans[x][y] = "b"

    ans = "\n".join("".join(x) for x in reversed(ans))
    print(ans)

def avator2operator(src='ArknightsGameData/zh_CN/gamedata/excel/character_table.json'):
    data = json.loads(open(src).read())
    return json.dumps({k:data[k]['name'] for k in data},ensure_ascii=False)

    

    



if __name__ == "__main__":
    fire.Fire()
