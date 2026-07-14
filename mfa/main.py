import subprocess
import sys
import textgrid
from pathlib import Path

def run_command(command):
  process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)

  while True:
    output = process.stdout.readline() # type: ignore
    if output == '' and process.poll() is not None:
      break
    if output:
      print(output.strip())
      sys.stdout.flush() 

  rc = process.poll()
  return rc

# Gerar pronúncia de palavras desconhecidas.
print("Gerando pronúncias")
try:
  result = run_command(["mfa", "g2p", "/data/input", "portuguese_brazil_mfa", "/data/output/g2pped_oovs.txt", "--dictionary_path", "portuguese_brazil_mfa", "--clean", "--single_speaker"])
  result = run_command(["mfa", "model", "add_words", "portuguese_brazil_mfa", "/data/output/g2pped_oovs.txt"])
except subprocess.CalledProcessError as e:
  print("Erro:", e.stderr)

# # Adaptar modelo acústico.
# print("Adaptando modelo acústico")
# try:
#   result = run_command(["mfa", "adapt", "/data/input", "portuguese_brazil_mfa", "portuguese_mfa", "/data/output/portuguese_brazil_mfa_adapted.zip", "--clean", "--single_speaker"])
# except subprocess.CalledProcessError as e:
#   print("Erro:", e.stderr)

# Gerar alinhamento de fonemas.
print("Alinhando fonemas")
try:
  result = run_command(["mfa", "align", "/data/input", "portuguese_brazil_mfa", "portuguese_mfa", "/data/output", "--clean", "--single_speaker"])
except subprocess.CalledProcessError as e:
  print("Command failed with error:", e.stderr)

first_textgrid = next(Path("/data/output").glob("*.TextGrid"), None)
if not first_textgrid:
  exit(1)
tg = textgrid.TextGrid.fromFile(first_textgrid.absolute())

output = "0.0 "
for interval in tg.tiers[1].intervals:
  output += interval.mark + "\n" + str(interval.maxTime) + " "

with open("/data/output/phonemes.txt", 'w', encoding='utf-8') as f:
  f.write(output)