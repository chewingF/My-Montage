//
//  MenuViewController.swift
//  My Montage
//
//  Created by 陈念 on 17/5/8.
//  Copyright © 2017年 nche75. All rights reserved.
//

import UIKit
import CoreData

class MenuViewController: UIViewController, UICollectionViewDelegate , UICollectionViewDataSource{
    //@this controller is for the main page with a list of all existing projects.

    //view
    @IBOutlet var MyCollectionView: UICollectionView!
    
    //buttons to be used
    @IBOutlet var CamButton: RoundButton!
    @IBOutlet var TrashButton: RoundButton!
    
    //variables to be used
    var CamCenter: CGPoint!
    var TrashCenter: CGPoint!
    var projectList = Array<Project>()
    var moveingItemIndexPath = IndexPath()
    
    //to set up basic things
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //lock oriention
        AppUtility.lockOrientation([.portrait], andRotateTo: .portrait)
        
        self.MyCollectionView.delegate = self
        self.MyCollectionView.dataSource = self
        
        
        //set delete area
        TrashButton.alpha = 0
        TrashButton.isEnabled = false
        CamButton.alpha = 1
        CamButton.isEnabled = true

        //hide navigation bar from start
        self.navigationController?.setNavigationBarHidden(true, animated:false)
        
    }

    //set positions for animation here to avoid screen size difference problem
    override func viewDidLayoutSubviews(){
        CamCenter = CamButton.center
        TrashCenter = TrashButton.center
    }
    
    //since this page can be accessed from camera page as well, need to reset project data ev every time.
    override func viewWillAppear(_ animated: Bool) {
        
        //set up Project list
        projectList.removeAll()
        
        let fetchRequest:NSFetchRequest<Project> = Project.fetchRequest()
        
        
        do{
            let searchResults = try MyDatabaseHelper.getContext().fetch(fetchRequest)
            for result in searchResults {
                if result.name == nil{
                    MyDatabaseHelper.getContext().delete(result)
                    MyDatabaseHelper.saveContext()
                }else{
                    projectList.append(result as Project!)
                }
            }
            
        }catch{
            print("Error: \(error)")
        }
        
        MyCollectionView.reloadData()
        //drag set up
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        MyCollectionView.addGestureRecognizer(longPressGesture)
        
    }

    
    override func viewDidDisappear(_ animated: Bool) {
        
        //lock oriention
        AppUtility.lockOrientation([.portrait], andRotateTo: .portrait)
    }

    
    
    //refresh the collectionview whenever call
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collection_cell" , for: indexPath) as! MyCollectionViewCell
        let show_Project:Project = projectList[indexPath.row]
        cell.setUp(setProject: show_Project)
        cell.updateFrame(parentFrame: collectionView.frame,index: indexPath.row)

        return cell
    }
    
    
    //return items number
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return projectList.count
    }

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let projectMoved = projectList.remove(at: moveingItemIndexPath.row)
        projectList.insert(projectMoved, at: destinationIndexPath.row)
        for c in collectionView.visibleCells{
            let cell = c as! MyCollectionViewCell
            let show_Project:Project = projectList[(collectionView.indexPath(for: c)?.row)!]
            cell.setUp(setProject: show_Project)
            cell.updateFrame(parentFrame: collectionView.frame,index: (collectionView.indexPath(for: c)?.row)!)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //long click function set uo
    func handleLongPress(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            //when long click start, drag start
            guard let selectedIndexPath = MyCollectionView?.indexPathForItem(at: gesture.location(in: MyCollectionView)) else {
                break
            }
            self.moveingItemIndexPath = (MyCollectionView?.indexPathForItem(at: gesture.location(in: MyCollectionView)))!

            self.TrashButton.backgroundColor = UIColor.clear
            self.TrashButton.isEnabled = true
            self.CamButton.isEnabled = false
            MyCollectionView?.beginInteractiveMovementForItem(at: selectedIndexPath)
            
            UIView.animate(withDuration: 0.3, animations: {
                self.TrashButton.alpha = 1
                self.TrashButton.center = self.CamCenter
            })
            UIView.animate(withDuration: 0.3, animations: {
                self.CamButton.alpha = 0
                self.CamButton.center = self.TrashCenter
            })
        case .changed:
            //when changed tap position, update data
            MyCollectionView?.updateInteractiveMovementTargetPosition(gesture.location(in: MyCollectionView))
            if self.TrashButton.frame.contains(gesture.location(in: self.view)){
                self.TrashButton.backgroundColor = UIColor.red
            } else {
                self.TrashButton.backgroundColor = UIColor.clear
            }
        case .ended:
            //when the drag ended, the operationwill be decided
            MyCollectionView?.endInteractiveMovement()

            if self.TrashButton.frame.contains(gesture.location(in: self.view)){
                checkDelete(CheckIndexPath: moveingItemIndexPath)
                
            }
            
            self.TrashButton.isEnabled = false
            self.CamButton.isEnabled = true
            UIView.animate(withDuration: 0.3, animations: {
                self.TrashButton.alpha = 0
                self.TrashButton.center = self.TrashCenter
            })
            
            UIView.animate(withDuration: 0.3, animations: {
                self.CamButton.alpha = 1
                self.CamButton.center = self.CamCenter
            })
            
            
        case .cancelled, .failed, .possible:
            //for accident situations
            self.TrashButton.isEnabled = false
            self.CamButton.isEnabled = true
            UIView.animate(withDuration: 0.3, animations: {
                self.TrashButton.alpha = 0
                self.TrashButton.center = self.TrashCenter
            })
            
            UIView.animate(withDuration: 0.3, animations: {
                self.CamButton.alpha = 1
                self.CamButton.center = self.CamCenter
            })
        }
    }
    
    //Check the delete of item and the delete process
    func checkDelete(CheckIndexPath : IndexPath){
        let cell = MyCollectionView.cellForItem(at: CheckIndexPath) as! MyCollectionViewCell
        let CheckProject = cell.project
        
        //remove from showing up
        if let index = projectList.index(of: cell.project ){
            projectList.remove(at: index)
        }
        
        let photoArraySet = CheckProject?.value(forKey: "photoCollection") as! NSOrderedSet
        let photoArray = photoArraySet.array as! [Photo]
        //delete all images firstly
        for p in photoArray{
            MyDatabaseHelper.getContext().delete(p)
        }
        //delete the project then
        MyDatabaseHelper.getContext().delete(CheckProject!)
        
        MyDatabaseHelper.saveContext()
        
        MyCollectionView.reloadData()
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Segues
    // sent the chosen project information to next controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openOldSegue" {
            if let indexPath = MyCollectionView.indexPathsForSelectedItems?[0]{
                let cell = MyCollectionView.cellForItem(at: indexPath) as! MyCollectionViewCell

                let oldProject  = cell.project
                let controller = (segue.destination as! ProjectViewController)
                controller.currentProject = oldProject
            }
        }
        //if new, create an empty project and save it.
        else if segue.identifier == "createNewSegue"{
                let newProject: Project = NSEntityDescription.insertNewObject(forEntityName: "Project", into: MyDatabaseHelper.getContext()) as! Project
                MyDatabaseHelper.saveContext()
                let controller = (segue.destination as! CameraViewController)
                controller.currentProject = newProject
        }
    }


}
