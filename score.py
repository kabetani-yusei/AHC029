import subprocess
import sys

# テストケースの範囲（0から99まで）
start_case = 0
end_case = 100

total_score = 0

for i in range(start_case, end_case):
    input_file = f"./in/{i:04d}.txt"
    output_file = f"./out/{i:04d}.txt"

    # main.rbの実行
    result = subprocess.run(["ruby", "main.rb"], stdin=open(input_file, "r"), stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

    # 結果の出力
    if result.returncode == 0:
        # 各ケースのスコアを取得し合計に加える
        try:
            score_line = result.stdout.strip().split('\n')[-1]
            score = int(score_line.split(':')[-1])
            total_score += score
            print(f"Test case {i:04d}: score = {score}")
        except (ValueError, IndexError):
            print(f"Failed to process {input_file}")
            sys.exit(1)
    else:
        print(f"Failed to process {input_file}")
        sys.exit(1)

    # 結果をファイルに書き込む
    with open(output_file, "w") as f:
        f.write(result.stdout)

print("Finished processing all test cases.")
print(f"Total Score: {total_score}")
