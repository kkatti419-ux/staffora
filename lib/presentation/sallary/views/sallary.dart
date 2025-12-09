// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';

// class SalaryPage extends StatelessWidget {
//   const SalaryPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xfff5f7fb),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: const Text(
//           "Salary & Payroll",
//           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ------------------ TOP SALARY CARD ----------------------
//             _salaryCard(),

//             const SizedBox(height: 20),

//             // ------------------ EARNINGS & DEDUCTIONS ----------------------
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(child: _earningsCard()),
//                 const SizedBox(width: 20),
//                 Expanded(child: _deductionsCard()),
//               ],
//             ),

//             const SizedBox(height: 20),

//             // ------------------ YEAR TO DATE SUMMARY ----------------------
//             _yearSummaryCard(),

//             const SizedBox(height: 20),

//             // ------------------ TREND CHART ----------------------
//             _salaryTrendChart(),

//             const SizedBox(height: 20),

//             // ------------------ RECENT PAYSLIPS ----------------------
//             _recentPayslips(),
//           ],
//         ),
//       ),
//     );
//   }

//   // ------------------ SALARY CARD ----------------------
//   Widget _salaryCard() {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xff3b5bff), Color(0xff7b2fff)],
//         ),
//         borderRadius: BorderRadius.circular(22),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text("Current Month Salary",
//               style: TextStyle(color: Colors.white, fontSize: 18)),
//           const SizedBox(height: 10),
//           const Text("₹60,300",
//               style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold)),
//           const SizedBox(height: 5),
//           const Text("December 2024",
//               style: TextStyle(color: Colors.white70, fontSize: 16)),
//           const SizedBox(height: 25),

//           // bottom 3 blocks
//           Row(
//             children: [
//               _smallCard("Gross Salary", "₹75,000"),
//               _smallCard("Total Deductions", "₹14,700"),
//               _smallCard("Net Pay", "₹60,300"),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _smallCard(String title, String value) {
//     return Expanded(
//       child: Container(
//         margin: const EdgeInsets.only(right: 12),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.20),
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(title,
//                 style: const TextStyle(color: Colors.white, fontSize: 14)),
//             const SizedBox(height: 6),
//             Text(value,
//                 style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold)),
//           ],
//         ),
//       ),
//     );
//   }

//   // ------------------ EARNINGS SECTION ----------------------
//   Widget _earningsCard() {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: _cardDecoration(),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _sectionTitle("Earnings Breakdown"),
//           _earnTile("Basic Salary", "Core compensation", "₹50,000"),
//           _earnTile("HRA", "House Rent Allowance", "₹15,000"),
//           _earnTile("Conveyance", "Transport Allowance", "₹3,000"),
//           _earnTile("Medical Allowance", "Health benefits", "₹2,000"),
//           _earnTile("Special Allowance", "Additional benefits", "₹5,000"),
//           Container(
//             padding: const EdgeInsets.all(14),
//             margin: const EdgeInsets.only(top: 10),
//             decoration: BoxDecoration(
//               color: Colors.green.shade400,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: const Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text("Total Earnings",
//                     style: TextStyle(color: Colors.white, fontSize: 16)),
//                 Text("₹75,000",
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _earnTile(String title, String subtitle, String value) {
//     return Container(
//       margin: const EdgeInsets.only(top: 12),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.green.shade50,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text(title, style: const TextStyle(fontSize: 16)),
//             Text(subtitle,
//                 style: const TextStyle(fontSize: 12, color: Colors.grey)),
//           ]),
//           Text(value,
//               style:
//                   const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }

//   // ------------------ DEDUCTIONS SECTION ----------------------
//   Widget _deductionsCard() {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: _cardDecoration(),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _sectionTitle("Deductions Breakdown"),
//           _dedTile("Provident Fund (PF)", "Employee contribution", "₹6,000"),
//           _dedTile("Income Tax (TDS)", "Tax deducted at source", "₹8,500"),
//           _dedTile("Professional Tax", "State tax", "₹200"),
//           Container(
//             padding: const EdgeInsets.all(14),
//             margin: const EdgeInsets.only(top: 10),
//             decoration: BoxDecoration(
//               color: Colors.red.shade400,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: const Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text("Total Deductions",
//                     style: TextStyle(color: Colors.white, fontSize: 16)),
//                 Text("₹14,700",
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold)),
//               ],
//             ),
//           ),
//           const SizedBox(height: 15),
//           Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [Color(0xff3b5bff), Color(0xff7b2fff)],
//               ),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: const Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text("Net Salary",
//                     style: TextStyle(color: Colors.white, fontSize: 16)),
//                 Text("₹60,300",
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _dedTile(String title, String subtitle, String value) {
//     return Container(
//       margin: const EdgeInsets.only(top: 12),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.red.shade50,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text(title, style: const TextStyle(fontSize: 16)),
//             Text(subtitle,
//                 style: const TextStyle(fontSize: 12, color: Colors.grey)),
//           ]),
//           Text(value,
//               style:
//                   const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }

//   // ------------------ YEAR SUMMARY ----------------------
//   Widget _yearSummaryCard() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: _cardDecoration(),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _sectionTitle("Year to Date Summary (2024)"),
//           Row(
//             children: [
//               _summaryBox("Total Earned", "₹900,000", Colors.green),
//               _summaryBox("Total Tax Paid", "₹102,000", Colors.red),
//               _summaryBox("Total PF", "₹72,000", Colors.blue),
//               _summaryBox("Net Received", "₹725,300", Colors.purple),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _summaryBox(String title, String value, Color color) {
//     return Expanded(
//       child: Container(
//         margin: const EdgeInsets.only(top: 10, right: 10),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(14),
//         ),
//         child: Column(
//           children: [
//             Text(title,
//                 style: const TextStyle(fontSize: 14, color: Colors.black87)),
//             const SizedBox(height: 6),
//             Text(value,
//                 style: TextStyle(
//                     fontSize: 18, fontWeight: FontWeight.bold, color: color)),
//           ],
//         ),
//       ),
//     );
//   }

//   // ------------------ CHART ----------------------
//   Widget _salaryTrendChart() {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: _cardDecoration(),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _sectionTitle("Salary Trend (Last 6 Months)"),
//           const SizedBox(height: 20),
//           SizedBox(
//             height: 260,
//             child: LineChart(
//               LineChartData(
//                 minY: 50000,
//                 maxY: 65000,
//                 titlesData: FlTitlesData(
//                   leftTitles: AxisTitles(
//                       sideTitles:
//                           SideTitles(showTitles: true, reservedSize: 40)),
//                   bottomTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       getTitlesWidget: (value, meta) {
//                         const labels = [
//                           "Jun",
//                           "Jul",
//                           "Aug",
//                           "Sep",
//                           "Oct",
//                           "Nov"
//                         ];
//                         return Text(labels[value.toInt()]);
//                       },
//                     ),
//                   ),
//                 ),
//                 lineBarsData: [
//                   LineChartBarData(
//                     isCurved: true,
//                     color: const Color(0xff3b5bff),
//                     barWidth: 3,
//                     dotData: FlDotData(show: true),
//                     spots: const [
//                       FlSpot(0, 60000),
//                       FlSpot(1, 60500),
//                       FlSpot(2, 60300),
//                       FlSpot(3, 60300),
//                       FlSpot(4, 60300),
//                       FlSpot(5, 60300),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ------------------ PAYSLIP LIST ----------------------
//   Widget _recentPayslips() {
//     final months = [
//       "December 2024",
//       "November 2024",
//       "October 2024",
//       "September 2024",
//       "August 2024",
//       "July 2024",
//     ];

//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: _cardDecoration(),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _sectionTitle("Recent Payslips"),
//           const SizedBox(height: 10),
//           ListView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: months.length,
//             itemBuilder: (context, i) {
//               return Container(
//                 margin: const EdgeInsets.only(bottom: 12),
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.description,
//                         size: 40, color: Color(0xff3b5bff)),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(months[i],
//                                 style: const TextStyle(
//                                     fontSize: 16, fontWeight: FontWeight.bold)),
//                             const Text("Net Pay: ₹60,300",
//                                 style: TextStyle(color: Colors.grey)),
//                           ]),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 14, vertical: 6),
//                       decoration: BoxDecoration(
//                           color: Colors.green.shade100,
//                           borderRadius: BorderRadius.circular(14)),
//                       child: const Text("Processed",
//                           style: TextStyle(color: Colors.green)),
//                     ),
//                     const SizedBox(width: 15),
//                     const Icon(Icons.visibility, color: Colors.blue),
//                     const SizedBox(width: 15),
//                     const Icon(Icons.download, color: Colors.blue),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   // ------------------ UTILS ----------------------
//   BoxDecoration _cardDecoration() {
//     return BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(18),
//     );
//   }

//   Widget _sectionTitle(String text) {
//     return Text(text,
//         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
//   }
// }

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SalaryPage extends StatelessWidget {
  const SalaryPage({super.key});

  bool isWeb(BuildContext context) => MediaQuery.of(context).size.width > 900;

  bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width > 600 &&
      MediaQuery.of(context).size.width <= 900;

  @override
  Widget build(BuildContext context) {
    final bool web = isWeb(context);
    final bool tab = isTablet(context);
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          "Salary & Payroll",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------ TOP SALARY CARD ------------------
            _salaryCard(width),

            const SizedBox(height: 20),

            // ------------------ EARNINGS & DEDUCTIONS ------------------
            if (width > 700)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _earningsCard(width)),
                  const SizedBox(width: 20),
                  Expanded(child: _deductionsCard(width)),
                ],
              )
            else
              Column(
                children: [
                  _earningsCard(width),
                  const SizedBox(height: 20),
                  _deductionsCard(width),
                ],
              ),

            const SizedBox(height: 20),

            // ------------------ YEAR SUMMARY ------------------
            _yearSummaryCard(width),

            const SizedBox(height: 20),

            // ------------------ TREND CHART ------------------
            _salaryTrendChart(width),

            const SizedBox(height: 20),

            // ------------------ RECENT PAYSLIPS ------------------
            _recentPayslips(width),
          ],
        ),
      ),
    );
  }

  // 🔵 TOP SALARY CARD (Responsive)
  Widget _salaryCard(double width) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff3b5bff), Color(0xff7b2fff)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Current Month Salary",
              style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 10),
          const Text("₹60,300",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          const Text("December 2024",
              style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 25),

          // 3 blocks become column on small screens
          width > 550
              ? Row(
                  children: [
                    _smallCard("Gross Salary", "₹75,000"),
                    _smallCard("Total Deductions", "₹14,700"),
                    _smallCard("Net Pay", "₹60,300"),
                  ],
                )
              : Column(
                  children: [
                    _smallCard("Gross Salary", "₹75,000"),
                    const SizedBox(height: 12),
                    _smallCard("Total Deductions", "₹14,700"),
                    const SizedBox(height: 12),
                    _smallCard("Net Pay", "₹60,300"),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _smallCard(String title, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.20),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(color: Colors.white, fontSize: 14)),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // ------------------ EARNINGS ------------------
  Widget _earningsCard(double width) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Earnings Breakdown"),

          // Tiles become stacked on small screens
          _earnTile("Basic Salary", "Core compensation", "₹50,000"),
          _earnTile("HRA", "House Rent Allowance", "₹15,000"),
          _earnTile("Conveyance", "Transport Allowance", "₹3,000"),
          _earnTile("Medical Allowance", "Health benefits", "₹2,000"),
          _earnTile("Special Allowance", "Additional benefits", "₹5,000"),

          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              color: Colors.green.shade400,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total Earnings",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                Text("₹75,000",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _earnTile(String title, String subtitle, String value) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            Text(subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ]),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ------------------ DEDUCTIONS ------------------
  Widget _deductionsCard(double width) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Deductions Breakdown"),
          _dedTile("Provident Fund (PF)", "Employee contribution", "₹6,000"),
          _dedTile("Income Tax (TDS)", "Tax deducted at source", "₹8,500"),
          _dedTile("Professional Tax", "State tax", "₹200"),
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total Deductions",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                Text("₹14,700",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff3b5bff), Color(0xff7b2fff)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Net Salary",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                Text("₹60,300",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dedTile(String title, String subtitle, String value) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            Text(subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ]),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ------------------ YEAR SUMMARY ------------------
  Widget _yearSummaryCard(double width) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Year to Date Summary (2024)"),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _summaryBox("Total Earned", "₹900,000", Colors.green, width),
              _summaryBox("Total Tax Paid", "₹102,000", Colors.red, width),
              _summaryBox("Total PF", "₹72,000", Colors.blue, width),
              _summaryBox("Net Received", "₹725,300", Colors.purple, width),
            ],
          )
        ],
      ),
    );
  }

  Widget _summaryBox(String title, String value, Color color, double width) {
    return SizedBox(
      width: width > 700 ? (width / 4) - 40 : width / 2 - 25,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(title,
                style: const TextStyle(fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  // ------------------ CHART ------------------
  Widget _salaryTrendChart(double width) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Salary Trend (Last 6 Months)"),
          const SizedBox(height: 20),
          SizedBox(
            height: width < 500 ? 200 : 260,
            child: LineChart(
              LineChartData(
                minY: 50000,
                maxY: 65000,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: true, reservedSize: 40)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const labels = [
                          "Jun",
                          "Jul",
                          "Aug",
                          "Sep",
                          "Oct",
                          "Nov"
                        ];
                        if (value < 0 || value > 5) return const SizedBox();
                        return Text(labels[value.toInt()]);
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: const Color(0xff3b5bff),
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    spots: const [
                      FlSpot(0, 60000),
                      FlSpot(1, 60500),
                      FlSpot(2, 60300),
                      FlSpot(3, 60300),
                      FlSpot(4, 60300),
                      FlSpot(5, 60300),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // ------------------ PAYSLIP LIST ------------------
  Widget _recentPayslips(double width) {
    final months = [
      "December 2024",
      "November 2024",
      "October 2024",
      "September 2024",
      "August 2024",
      "July 2024",
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Recent Payslips"),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: months.length,
            itemBuilder: (context, i) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.description,
                            size: 40, color: Color(0xff3b5bff)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(months[i],
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                const Text("Net Pay: ₹60,300",
                                    style: TextStyle(color: Colors.grey)),
                              ]),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(14)),
                          child: const Text("Processed",
                              style: TextStyle(color: Colors.green)),
                        ),
                      ],
                    ),
                    if (width < 600) const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: width < 600
                          ? MainAxisAlignment.spaceAround
                          : MainAxisAlignment.end,
                      children: const [
                        Icon(Icons.visibility, color: Colors.blue),
                        SizedBox(width: 20),
                        Icon(Icons.download, color: Colors.blue),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ------------------ UTILS ------------------
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Text(text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }
}
