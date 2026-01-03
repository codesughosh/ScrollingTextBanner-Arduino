import serial
import time
import tkinter as tk

# -------- SERIAL CONFIG --------
PORT = "COM5"
BAUD = 9600
WIDTH = 16
# --------------------------------

ser = serial.Serial(PORT, BAUD, timeout=1)
time.sleep(2)

# -------- TKINTER WINDOW --------
root = tk.Tk()
root.title("Scrolling Text Banner")
root.geometry("1000x260")
root.configure(bg="black")

# -------- MATRIX PANEL (FIXED SIZE) --------
panel = tk.Frame(
    root,
    bg="black",
    width=900,
    height=160,
    highlightbackground="#003300",
    highlightthickness=4
)
panel.pack(expand=True)
panel.pack_propagate(False)   # 🔑 IMPORTANT

# -------- GLOW LABELS (CENTERED) --------
glow_far = tk.Label(
    panel,
    text=" " * WIDTH,
    font=("Lucida Console", 54, "bold"),
    fg="#003300",
    bg="black"
)
glow_far.place(relx=0.5, rely=0.5, anchor="center", x=3, y=3)

glow_near = tk.Label(
    panel,
    text=" " * WIDTH,
    font=("Lucida Console", 54, "bold"),
    fg="#00aa44",
    bg="black"
)
glow_near.place(relx=0.5, rely=0.5, anchor="center", x=1, y=1)

label = tk.Label(
    panel,
    text=" " * WIDTH,
    font=("Lucida Console", 54, "bold"),
    fg="#00ff66",   # MATRIX GREEN
    bg="black"
)
label.place(relx=0.5, rely=0.5, anchor="center")

# -------- SERIAL FRAME READER --------
def read_frame():
    try:
        frame = ser.read_until(b'\r').decode(errors="ignore").strip()
        if frame:
            frame = frame.ljust(WIDTH)

            glow_far.config(text=frame)
            glow_near.config(text=frame)
            label.config(text=frame)

    except:
        label.config(text="SERIAL ERROR")

    root.after(150, read_frame)   # smooth + visible

read_frame()
root.mainloop()
