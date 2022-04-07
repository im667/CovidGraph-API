//
//  ViewController.swift
//  CovidGraph-API
//
//  Created by mac on 2022/04/05.
//

import UIKit
import Charts
import Alamofire

class ViewController: UIViewController {

    
    @IBOutlet weak var caseLabel: UILabel!
    
    @IBOutlet weak var newCaseLabel: UILabel!
    
    @IBOutlet weak var pieChartView: PieChartView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.fetchCovidOverview(completionHandler: {[weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(result):
                self.configurStackView(koreaCovidOverview: result.korea)
                let covidOverviewList = self.makeCovidOverviewList(cityCovidOverview: result)
                self.configurChartView(covidOverviewList: covidOverviewList)
                
            case let .failure(error):
                debugPrint(error)
            }
        })
        
        
    }


    
    func makeCovidOverviewList(
        cityCovidOverview:CityCovidOverview
    )->[CovidOverview] {
        return [
            cityCovidOverview.seoul,
            cityCovidOverview.busan,
            cityCovidOverview.incheon,
            cityCovidOverview.daegu,
            cityCovidOverview.sejong,
            cityCovidOverview.chungnam,
            cityCovidOverview.daejeon,
            cityCovidOverview.chungbuk,
            cityCovidOverview.gangwon,
            cityCovidOverview.gyeonggi,
            cityCovidOverview.ulsan,
            cityCovidOverview.gwangju,
            cityCovidOverview.jeonnam,
            cityCovidOverview.jeonbuk,
            cityCovidOverview.gyeongbuk,
            cityCovidOverview.gyeongnam,
            cityCovidOverview.jeju
            
        ]
    }
    
    func configurChartView(covidOverviewList: [CovidOverview]){
        let entrise = covidOverviewList.compactMap { [weak self] overView -> PieChartDataEntry? in
            guard let self = self else { return nil }
            return PieChartDataEntry(
                value: self.removeFormatString(string: overView.newCase),
                label: overView.countryName,
                data: overView
            )
        }
        let dataSet = PieChartDataSet(entries: entrise, label: "코로나 발생 현황")
        self.pieChartView.data = PieChartData(dataSet: dataSet)
    }
    
    func removeFormatString(string: String)-> Double {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.number(from: string)?.doubleValue ?? 0
    }
    
    func configurStackView(koreaCovidOverview: CovidOverview) {
        self.caseLabel.text = "\(koreaCovidOverview.totalCase)명"
        self.newCaseLabel.text = "\(koreaCovidOverview.newCase)명"
    }
    
    
    func fetchCovidOverview(
        completionHandler: @escaping (Result<CityCovidOverview, Error>) -> Void
    ){
        let url = "https://api.corona-19.kr/korea/country/new/"
        let param = Key.param
        AF.request(url, method: .get, parameters: param)
            .responseData(completionHandler: {response in
                switch response.result {
                case let .success(data):
                    do {
                        let decoder = JSONDecoder()
                        let result = try decoder.decode(CityCovidOverview.self, from: data)
                        completionHandler(.success(result))
                    } catch {
                        completionHandler(.failure(error))
                    }
                    
                case let .failure(error):
                    completionHandler(.failure(error))
                }
            })
    }


}

