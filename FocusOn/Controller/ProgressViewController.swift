//
//  ProgressViewController.swift
//  FocusOn
//
//  Created by Michael Gresham on 03/05/2020.
//  Copyright © 2020 Michael Gresham. All rights reserved.
//

import Foundation
import UIKit
import Charts
import CoreData

class ProgressViewController: UIViewController, UIGestureRecognizerDelegate {
    let dataController = DataController()
    var weekDate = Date.init()
    var yearDate = Date.init()
    var tasksCount = 3
    var firstEntry = Date.init()
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var viewSegment: UISegmentedControl!
    @IBOutlet weak var barChartView: BarChartView!
    
    @IBAction func viewSegmentChanged(_ sender: Any) {
        self.configure()
        self.setData()
    }
    @IBAction func previousButton(_ sender: Any) {
        switch viewSegment.selectedSegmentIndex {
        case 0:
            if (weekDate - TimeInterval(7 * 24 * 3600)) < dataController.firstDayOfWeek(for: firstEntry) {
                present(AlertContoller.init().pastAlertContoller(self), animated: true)
            } else {
            weekDate -= TimeInterval(7 * 24 * 3600)
            }
        case 1:
            if (yearDate - TimeInterval(365 * 24 * 3600)) < dataController.firstDayOfYear(for: firstEntry) {
                present(AlertContoller.init().pastAlertContoller(self), animated: true)
            } else {
            yearDate -= TimeInterval(365 * 24 * 3600)
            }
        default:
            break
        }
        setData()
        configure()
    }
    @IBAction func nextButton(_ sender: Any) {
        switch viewSegment.selectedSegmentIndex {
        case 0:
            if (weekDate + TimeInterval(7 * 24 * 3600)) > dataController.today {
                present(AlertContoller.init().futureAlertContoller(self), animated: true)
            } else {
            weekDate += TimeInterval(7 * 24 * 3600)
            }
            
        case 1:
            if (yearDate + TimeInterval(365 * 24 * 3600)) > dataController.today {
                present(AlertContoller.init().futureAlertContoller(self), animated: true)
            } else {
            yearDate += TimeInterval(365 * 24 * 3600)
            }
        default:
            break
        }
        setData()
        configure() 
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        weekDate = dataController.firstDayOfWeek(for: Date.init())
        yearDate = dataController.firstDayOfYear(for: Date.init())
        firstEntry = dataController.fetchFirstDate()
        print(dataController.dateCaption(for: firstEntry))
        configure()
        setData()
        setSwipeGestures()
    }
    func setSwipeGestures() {
        //let gestureView = UIView(frame: barChartView.frame)
       // gestureView.addConstraints(barChartView.constraints)
        //self.view.addSubview(gestureView)
        barChartView.gestureRecognizers?.forEach(barChartView.removeGestureRecognizer(_:))
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeBarChart(_sender:
            )))
        leftSwipeGestureRecognizer.direction = .left
        let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeBarChart(_sender:
        )))
        rightSwipeGestureRecognizer.direction = .right
        barChartView.addGestureRecognizer(leftSwipeGestureRecognizer)
        barChartView.addGestureRecognizer(rightSwipeGestureRecognizer)
        leftSwipeGestureRecognizer.delegate = self
        rightSwipeGestureRecognizer.delegate = self
    }
    @objc func swipeBarChart(_sender:UISwipeGestureRecognizer) {
        if _sender.state == .ended {
            if _sender.direction == .left {
                self.nextButton(_sender)
            } else {
                self.previousButton(_sender)
            }
        }
    }
    func configure() {
        let legend = barChartView.legend
        legend.horizontalAlignment = .center
        legend.verticalAlignment = .top
        legend.orientation = .horizontal
        legend.font = UIFont.init(name: "Avenir-Medium", size: 16)!

        let xAxis = barChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = false
        xAxis.centerAxisLabelsEnabled = false
        xAxis.drawLabelsEnabled = true
        xAxis.drawAxisLineEnabled = false
        xAxis.labelFont = UIFont.init(name: "Avenir-Book", size: 12)!
        
        let leftAxis = barChartView.leftAxis
        leftAxis.axisMinimum = 0.0
        leftAxis.drawGridLinesEnabled = true
        leftAxis.drawZeroLineEnabled = true
        leftAxis.labelFont = UIFont.init(name: "Avenir-Book", size: 12)!
        
        
        barChartView.rightAxis.drawLabelsEnabled = false
        barChartView.rightAxis.drawGridLinesEnabled = false
        barChartView.drawGridBackgroundEnabled = true
        barChartView.isUserInteractionEnabled = true
        
        switch viewSegment.selectedSegmentIndex {
        case 0:
            xAxis.labelCount = 7
            leftAxis.labelCount = tasksCount + 1
            leftAxis.axisMaximum = Double(tasksCount + 1) 
        case 1:
            xAxis.labelCount = 12
            leftAxis.labelCount = 6
            leftAxis.axisMaximum = 31
        default:
            break
        }
    }
    
    func setData() {
        var completedEntries = [BarChartDataEntry]()
        var totalEntries = [BarChartDataEntry]()
        var completedLabel = String()
        var totalLabel = String()
        var xAxisLabels = [String]()
        
        switch viewSegment.selectedSegmentIndex {
        case 0:
            tasksCount = 0
            self.dateLabel.text = dataController.weekCaption(for: weekDate)
            var data: [(completed: Int, total: Int)] = []
            data = dataController.dataForWeek(week: weekDate)
            for i in 0 ..< data.count{
                completedEntries.append(BarChartDataEntry(x: Double(i), y: Double(data[i].completed)))
                totalEntries.append(BarChartDataEntry(x: Double(i), y: Double(data[i].total)))
                tasksCount = tasksCount < data[i].total ? data[i].total : tasksCount
            }
            xAxisLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
            completedLabel = "Tasks Completed"
            totalLabel = "Total Tasks"
        case 1:
            self.dateLabel.text = dataController.yearCaption(for: yearDate)
            var data: [(completed: Int, total: Int)] = []
            data = dataController.dataForYear(year: yearDate)
            for i in 0 ..< data.count{
                completedEntries.append(BarChartDataEntry(x: Double(i), y: Double(data[i].completed)))
                totalEntries.append(BarChartDataEntry(x: Double(i), y: Double(data[i].total)))
            }
            xAxisLabels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
            completedLabel = "Goals Completed"
            totalLabel = "Total Goals"
        default:
            break
        }
        
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xAxisLabels)
        barChartView.xAxis.granularity = 1
        
        let dataSet = BarChartDataSet(entries: completedEntries, label: completedLabel)
        dataSet.drawValuesEnabled = false
        dataSet.setColor(UIColor.init(red: 108/255, green: 215/255, blue: 180/255, alpha: 1), alpha: 1)

        let dataSet2 = BarChartDataSet(entries: totalEntries, label: totalLabel)
        dataSet2.drawValuesEnabled = false
        dataSet2.setColor(UIColor.init(red: 0/255, green: 169/255, blue: 114/255, alpha: 1), alpha: 1)
        
        let barWidth = Double(0.42)
        let barSpace = Double(0.03)
        let groupSpace = Double(0.10)
        let chartData = BarChartData(dataSets: [dataSet, dataSet2])
        chartData.barWidth = barWidth

        barChartView.data = chartData
        barChartView.groupBars(fromX: -0.5, groupSpace: groupSpace, barSpace: barSpace)
        barChartView.invalidateIntrinsicContentSize()
        barChartView.animate(yAxisDuration: 0.5, easingOption: .easeOutBack)
    }
}

