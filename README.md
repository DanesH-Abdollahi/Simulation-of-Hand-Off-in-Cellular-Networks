# Simulation-of-Hand-Off-in-Cellular-Networks
In this project we study different algorithms used in handoff decision making in a micro-cellular network. The scenario is depicted in Figure-1, BS 1-4 are four base stations in a cellular network. MH represents a mobile host, which is in the coverage area of BS1 and communicating through BS1. The MH starts moving away from BS1 towards BS2. As the MH moves away the received signal strength (RSS) from BS1 decreases and the RSS from BS2-4 increases. At certain points received power from BS-1 becomes weak and MH starts to search for another BS which can provide a stronger signal and selects that base station as its point of connection. In an ideal system we would expect to develop an algorithm that can make the handoff decision only once and preferably in the middle of the path between BS1 and BS2. We are going to study four algorithms in that respect.


![](/figures/fig.png)


---
### Handoff Decision Making Algorithms
RSS algorithm In this method MH is always monitoring the Received Signal Strength (RSS) values from each of the four
base stations and selects the one who provides the strongest signal. Figure-2a shows the flow chart for this algorithm.


### RSS with threshold
In this method, similar to the previous method, RSS is the metric for handoff. However, MH does not compare the values of RSS from all BSs until the received power from the existing BS goes below a certain threshold. Figure-2b shows the flow chart for this algorithm.


### RSS with hysteresis in RSS
In this method, similar to previous methods the primary metric for handoff decision is still RSS. However, MH selects a different base station whenever the RSS from a base station is more than the RSS from the current base station plus a hysteresis (given constant parameter) value. Figure-2c shows the flow chart for this algorithm.

---
### RSS with hysteresis in RSS and threshold
This method is a combination of the all previously mentioned methods. If the RSS from the current base station drops below a certain threshold the mobile host selects the BS which provides RSS which is more than the RSS from the current base station plus a hysteresis. Figure-2d shows the flow chart for this algorithm.

---
### Assumptions for the Project
- Mobile host user is walking from the neighborhood of BS1 toward BS2 as indicated in figure 1 with a constant speed of 1 m/Sec.
- The distance of a block, R, shown in figure 1, is R = 250 m

- Received Signal Strength is calculated as shown in the appendix.

- The sampling frequency is 10 Hz, in another words MH measures RSS in every 0.1 Sec

- For the part which we use a threshold assume Threshold = -68 dbm

- For the part which we use hysteresis assume Hysteresis = 5 dbm 

---

---

### Deliverables for the Assignment
- Channel profile, which is the RSS from each of the base stations.

- Probability Density Function (PDF) of number of handoffs.
    - Note: in an ideal system we are looking for one hand off just in the middle point of the path.

- Probability Density Function (PDF) of hand off location.

---

### Results
![](/figures/fig1.png)

![](/figures/fig2.png)

![](/figures/fig3.png)

![](/figures/fig4.png)
